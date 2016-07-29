#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'pry'
require 'pry-byebug'
require 'puppetclassify'

@real_nodes = [
  'node0.puppet.vm',
  'node1.puppet.vm',
  'node2.puppet.vm',
  'node3.puppet.vm'
]

@user_resources = [
  'ブレット',
  'ディラン',
  'ジェシー',
  'Rößle'
]

@group_resources = [
  'オージー',
  'ブレット_grp',
  'ディラン_grp',
  'ジェシー_grp',
  'Rößle_grp'
]

@not_so_real_nodes = [
  'win0.puppet.vm',
  'win1.puppet.vm'
]

@registry_resources = [
  'ビール',
  'bier',
  'bière',
  'пиво'
]

# Have puppet parse its config so we can call its settings
Puppet.initialize_settings

def cputs(string)
    puts "\033[1m#{string}\033[0m"
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
      resource = JSON.parse(@api_setup.get(URI.escape("#{@puppetdb_url}/query/v4/resources?query=[\"and\",[\"=\",\"certname\",\"#{node_name}\"],[\"=\",\"type\",\"#{resource_type.capitalize}\"],[\"=\",\"title\",\"#{resource_title}\"]]")).body)
      if resource.any?
        puts "Success for #{node_name} for resource type #{resource_type.capitalize} and title #{resource_title}"
      else
        puts "Fail, cannot find resource type #{resource_type.capitalize} and title #{resource_title} for #{node_name}"
      end
    end
  end
end

get_data(@real_nodes + @not_so_real_nodes, 'User', @user_resources)
get_data(@real_nodes + @not_so_real_nodes, 'Group', @group_resources)
get_data(@not_so_real_nodes, 'Registry::Value', @registry_resources)
