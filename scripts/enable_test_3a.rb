#!/opt/puppetlabs/puppet/bin/ruby
require 'puppetclassify'
require 'puppet'

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

@base_this_test = {
'role::base' => {
  "utf_8_notify_string"   => "こんにちは",
  "ensure_utf_8_concat"   => false,
  "ensure_utf_8_registry" => false,
  "ensure_utf_8_exported" => false,
  "ensure_utf_8_virtual"  => false,
  "ensure_utf_8_static"   => false,
  "ensure_utf_8_group"    => false,
  "ensure_utf_8_files"    => true,
  "ensure_utf_8_nrp"      => false,
  "ensure_utf_8_host"     => false,
  "ensure_utf_8_users"    => false,
  "ensure_utf_8_lookup"   => false
}
}

def cputs(string)
  puts "\033[1m#{string}\033[0m"
end

# Have puppet parse its config so we can call its settings
Puppet.initialize_settings

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

def update_master(mod_group, added_classes)
  cputs "Updating #{mod_group} Node Group"
  load_classifier
  @classifier.update_classes.update
  groups = @classifier.groups

  node_group = groups.get_groups.select { |group| group['name'] == mod_group}

  raise "#{mod_group} group missing!" if node_group.empty?

  group_hash = node_group.first.merge({"classes" => added_classes})
  groups.update_group(group_hash)
end

update_master('ウェブ・グループ',@base_this_test)
