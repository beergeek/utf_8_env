#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'puppetclassify'

@base_group_default = {
  'role::base' => {
    "utf_8_notify_string"   => "こんにちは",
    "ensure_utf_8_concat"   => false,
    "ensure_utf_8_registry" => false,
    "ensure_utf_8_exported" => false,
    "ensure_utf_8_virtual"  => false,
    "ensure_utf_8_static"   => false,
    "ensure_utf_8_group"    => false,
    "ensure_utf_8_files"    => false,
    "ensure_utf_8_nrp"      => false,
    "ensure_utf_8_host"     => false,
    "ensure_utf_8_users"    => false,
    "ensure_utf_8_lookup"   => false
  }
}

@real_nodes = [
  'node2.puppet.vm',
  'node3.puppet.vm'
]

@user_resources = [
  '奪います',
  'ジョー',
]

@file_resources = [
  '/home/奪います',
  '/home/奪います/.puppetlabs',
  '/home/奪います/.puppetlabs/etc',
  '/home/奪います/.puppetlabs/puppet',
  '/home/奪います/.puppetlabs/puppet/puppet.conf',
]

@ini_resources = [
  'rob_certificate',
  'joe_certificate',
  'rob_user',
  'joe_user',
  'rob_server',
  'joe_server'
]

@nrp_certs = [
  'joe_node2',
  'rob_node2',
  'joe_node3',
  'rob_node3'
]

# Have puppet parse its config so we can call its settings
Puppet.initialize_settings

def cputs(string)
    puts "\033[1m#{string}\033[0m"
end

class PuppetHttps
  def get_with_token(url)
    url = URI.parse(url)
    accept = 'application/json'
    token = File.read('/root/.puppetlabs/token')

    req = Net::HTTP::Get.new("#{url.path}?#{url.query}", {"Accept" => accept, "X-Authentication" => token})
    res = make_ssl_request(url, req)
    res
  end

  def post_with_token(url, request_body=nil)
    url = URI.parse(url)
    token = File.read('/root/.puppetlabs/token')

    request = Net::HTTP::Post.new(url.request_uri, {"X-Authentication" => token})
    request.content_type = 'application/json'

    unless request_body.nil?
      request.body = request_body
    end

    res = make_ssl_request(url, request)
    res
  end
end

# get Puppet master name
def load_config
  master = Puppet.settings[:server]
  @master = master
  if master
    @classifier_url   = "https://#{master}:4433/classifier-api"
    @rbac_url         = "https://#{master}:4433/rbac-api"
    @puppet_ca_url    = "https://#{master}:8140/puppet-ca"
    @puppetdb_url     = "https://#{master}:8081/pdb"
    @puppet_url       = "https://#{master}:8140/puppet"
    @status_url       = "https://#{master}:8140/status"
    @orchestrator_url = "https://#{master}:8143/orchestrator"
    @activity_url     = "https://#{master}:4433/activity-api"
    @ca_url           = "https://#{master}:8140/puppet-ca"
    auth_info = {
      'ca_certificate_path' => Puppet[:localcacert],
      'certificate_path'    => Puppet[:hostcert],
      'private_key_path'    => Puppet[:hostprivkey],
    }
    unless @api_setup
      @api_setup = PuppetHttps.new(auth_info)
    end
  else
    cputs "No master!"
  end
end

def get_data(node_names, resource_type, resource_titles)
  load_config
  node_names.each do |node_name|
    resource_titles.each do |resource_title|
      resource = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4/resources?query=[\"and\",[\"=\",\"certname\",\"#{node_name}\"],[\"=\",\"type\",\"#{resource_type.capitalize}\"],[\"=\",\"title\",\"#{resource_title}\"]]")).body)
      if resource.any?
        puts "Success for #{node_name} for resource type #{resource_type.capitalize} and title #{resource_title}"
      else
        puts "Fail, cannot find resource type #{resource_type.capitalize} and title #{resource_title} for #{node_name}"
      end
    end
  end
end

def update_master(mod_group, added_classes)
  cputs "Updating #{mod_group} Node Group"
  load_config
  groups = JSON.parse(@api_setup.get_with_token("#{@classifier_url}/v1/groups").body)

  node_group = groups.select { |group| group['name'] == mod_group}

  raise "#{mod_group} group missing!" if node_group.empty?

  group_hash = node_group.first.merge({"classes" => added_classes})
  update_group = @api_setup.post_with_token("#{@classifier_url}/v1/groups/#{group_hash['id']}",group_hash.to_json)
  if update_group.code.to_i != 200
    cputs "Failed to update #{mod_group} #{update_group.code}"
  else
    cputs "Success in updating #{mod_group}"
  end
end

def get_certs(cert_names)
  load_config
  cert_names.each do |cert_name|
    cert = @api_setup.get("#{@ca_url}/v1/certificate/#{cert_name}")
    if cert.code.to_i == 200
      cputs "Success. Certificate found for #{cert_name}"
    else
      cputs "Fail. Certificate NOT found for #{cert_name}: #{cert.code}"
    end
  end
end

get_data(@real_nodes, 'User', @user_resources)
get_data(@real_nodes, 'File', @file_resources)
get_data(@real_nodes, 'Pe_ini_setting', @ini_resources)
get_certs(@nrp_certs)
update_master('ウェブ・グループ',@base_group_default)
