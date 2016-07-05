#!/bin/bash

[[ $EUID -eq 0 ]] || { echo "${0##*/} must be run as root or with sudo" >&2; exit 1; }

echo "==> Fixing permissions on the code-staging directory"
chown -R pe-puppet:pe-puppet /etc/puppetlabs/code-staging

echo "==> Running r10k manually as pe-puppet to fetch new code"
sudo -u pe-puppet bash -c '/opt/puppetlabs/puppet/bin/r10k deploy environment -c /opt/puppetlabs/server/data/code-manager/r10k.yaml -p -v debug'

deploy_result=$?
[[ $deploy_result -eq 0 ]] || { echo -e "\nR10k failed to deploy your code. Check the scroll-back for errors.\n" >&2; exit 1; }

echo "==> Delete environments in the code-dir so file-sync can do its thing"
rm -rf /etc/puppetlabs/code/*

echo "==> Fixing permissions on the code directory"
chown pe-puppet:pe-puppet /etc/puppetlabs/code

echo "==> Starting pe-puppetserver"
/opt/puppetlabs/puppet/bin/puppet resource service pe-puppetserver ensure=running

# Determine paths to certs.
certname="$(puppet agent --configprint certname)"
certdir="$(puppet agent --configprint certdir)"

# Set variables for the curl.
cert="${certdir}/${certname}.pem"
key="$(puppet agent --configprint privatekeydir)/${certname}.pem"
cacert="${certdir}/ca.pem"

echo "==> Hitting the file-sync commit endpoint at https://$(hostname -f):8140/file-sync/v1/commit"
/opt/puppetlabs/puppet/bin/curl -v -s --request POST --header "Content-Type: application/json" --data '{"commit-all": true}' \
  --cert "$cert" \
  --key "$key" \
  --cacert "$cacert" \
  "https://$(hostname -f):8140/file-sync/v1/commit" && echo
