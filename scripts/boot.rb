#!/opt/puppetlabs/puppet/bin/ruby
require 'puppetclassify'
require 'getoptlong'
require 'puppet'
require 'hiera'
require 'facter'
require 'r10k/action/deploy/environment'
require 'r10k/action/runner'

def cputs(string)
  puts "\033[1m#{string}\033[0m"
end

# Have puppet parse its config so we can call its settings
Puppet.initialize_settings

def config_r10k(remote)
  cputs "Configuring r10k"
  load_classifier
  conf = Puppet::Resource.new("file",'/etc/puppetlabs/r10k/r10k.yaml', :parameters => {
    :ensure => 'file',
    :owner  => 'root',
    :group  => 'root',
    :mode   => '0644',
    :content => "cachedir: '/var/cache/r10k'\n\nsources:\n  code:\n    remote: '#{remote}'\n    basedir: '/etc/puppetlabs/code/environments'"
  })
  result, report = Puppet::Resource.indirection.save(conf)
  puts report.logs

  options = {
    :puppetfile => true,
    :config     => '/etc/puppetlabs/r10k/r10k.yaml',
    :loglevel   => 'info'
  }
  my_action = R10K::Action::Deploy::Environment

  runner = R10K::Action::Runner.new(options, [], my_action)
  runner.call
  cputs "Finished r10k"
  @classifier.update_classes.update
end

# Read classifier.yaml for split installation compatibility
def load_classifier_config
  configfile = File.join Puppet.settings[:confdir], 'classifier.yaml'
  if File.exist?(configfile)
    classifier_yaml = YAML.load_file(configfile)
    @classifier_url = "https://#{classifier_yaml['server']}:#{classifier_yaml['port']}/classifier-api"
  else
    Puppet.debug "Config file #{configfile} not found"
    puts "no config file! - wanted #{configfile}"
    exit 2
  end
end

# Create classifier instance var
# Uses the local hostcertificate for auth ( assume we are
# running from master in whitelist entry of classifier ).
def load_classifier()
  auth_info = {
    'ca_certificate_path' => Puppet[:localcacert],
    'certificate_path'    => Puppet[:hostcert],
    'private_key_path'    => Puppet[:hostprivkey],
  }
  unless @classifier
    load_classifier_config
    @classifier = PuppetClassify.new(@classifier_url, auth_info)
  end
end

# Add parent group as PE Infrasture so we can steal the params
# from there that the default install lays down
def create_group(group_name,group_uuid,classes = {},rule_term,parent_group)
  load_classifier
  groups = @classifier.groups
  @classifier.update_classes.update
  current_group = groups.get_groups.select { |group| group['name'] == group_name}
  if current_group.empty?
    cputs "Creating #{group_name} group in classifier"
    groups.create_group({
      'name'    => group_name,
      'id'      => group_uuid,
      'classes' => classes,
      'parent'  => groups.get_group_id("#{parent_group}"),
      'rule'    => rule_term
    })
  else
    cputs "NODE GROUP #{group_name} ALREADY EXISTS!!! Skipping"
  end
end

def new_groups()
  cputs = "Making New Node Groups"
  web_group = {
    'role::web_server' => {}
  }

  app_group = {
    'role::app_server' => {}
  }

  db_group = {
    'role::db_server' => {}
  }
  #Web Group
  create_group("ウェブ・グループ",'937f05eb-8185-4517-a609-3e64d05191c2',web_group,["and", ["~", ["fact","pp_role"],'ウェブ_サーバ']],"All Nodes")
  #Application Group
  create_group("アプリケーション・グループ",'937f05eb-8185-4517-a609-3e64d05191c1',app_group,["and",["~",["fact","pp_role"],'アプリ_サーバ']],'All Nodes')
  #Databse Group
  create_group("データベース・グループ",'937f05eb-8185-4517-a609-3e64d05191ca',db_group,["and", ["~", ["fact","pp_role"],'db_サーバ']],'All Nodes')
end

def change_classification()
  cputs "Update Node Groups"
  master_rule = ["and",["=","name","master.puppet.vm"]]
  master_classes = {
    'pe_repo' => {},
    'pe_repo::platform::el_7_x86_64' => {},
    'pe_repo::platform::el_6_x86_64' => {},
    'pe_repo::platform::ubuntu_1604_amd64' => {},
    'pe_repo::platform::windows_x86_64' => {},
    'puppet_enterprise::profile::master' => {},
    'puppet_enterprise::profile::master::mcollective' => {},
    'puppet_enterprise::profile::mcollective::peadmin' => {}
  }

  update_node_group(
    "PE Master",
    master_rule,
    master_classes
  )

end

def update_node_group(node_group,rule,classes)
  cputs "Update Node Group #{node_group}"
  load_classifier
  groups = @classifier.groups
  pe_group = groups.get_groups.select { |group| group['name'] == "#{node_group}"}

  if classes
    group_hash = pe_group.first.merge({"classes" => classes})
    groups.update_group(group_hash)
  end
  group_hash = pe_group.first.merge({ "rule" => rule})

  groups.update_group(group_hash)
end

config_r10k('https://github.com/beergeek/japan_test.git')
new_groups()
change_classification()
