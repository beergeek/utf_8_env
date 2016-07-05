#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'puppetclassify'

# We are making a wild-arse assumption there that we have a monolithic install!
# Remember kids, this is only for testing not the real world......
# As the real world is fucking scary!

@aussie_pses = [
  { 'login' => 'ブレット',
    'display_name' => 'ブレット',
    'email' => 'ブレット@puppet.com',
    'role_ids' => [1]
  },
  { 'login' => 'ディラン',
    'display_name' => 'ディラン',
    'email' => 'ディラン@puppet.com',
    'role_ids' => [1]
  },
  { 'login' => 'ジェシー',
    'display_name' => 'ジェシー',
    'email' => 'ジェシー@puppet.com',
    'role_ids' => [1]
  },
  { 'login' => 'Rößle',
    'display_name' => 'Rößle',
    'email' => 'Rößle@puppet.vm',
    'role_ids' => [1]
  }
]
@aussie_groups = [
  {
    "login" => "オージー",
    "role_ids" => [1]
  }
]
@aussie_roles = [
  {
    "display_name" => 'オージー',
    "user_ids" => [],
    "group_ids" => [],
    "description" => "こんにちは UTF-8 Testing",
    "permissions" => [
      {
        "object_type" => "console_page",
        "action" => "view",
        "instance" => "*"
      },
      {
        "object_type" => "node_groups",
        "action" => "modify_children",
        "instance" => "*"
      },
      {
        "object_type" => "puppet_agent",
        "action" => "run",
        "instance" => "*"
      },
      {
        "object_type" => "node_groups",
        "action" => "set_environment",
        "instance" => "*"
      },
      {
        "object_type" => "cert_requests",
        "action" => "accept_reject",
        "instance" => "*"
      },
      {
        "object_type" => "node_groups",
        "action" => "edit_classification",
        "instance" => "*"
      },
      {
        "object_type" => "tokens",
        "action" => "override_lifetime",
        "instance" => "*"
      },
      {
        "object_type" => "nodes",
        "action" => "view_data",
        "instance" => "*"
      },
      {
        "object_type" => "environment",
        "action" => "deploy_code",
        "instance" => "*"
      },
      {
        "object_type" => "nodes",
        "action" => "edit_data",
        "instance" => "*"
      },
      {
        "object_type" => "node_groups",
        "action" => "edit_child_rules",
        "instance" => "*"
      },
      {
        "object_type" => "orchestration",
        "action" => "use",
        "instance" => "*"
      },
      {
        "object_type" => "node_groups",
        "action" => "view",
        "instance" => "*"
      }
    ]
  }
]


# Have puppet parse its config so we can call its settings
Puppet.initialize_settings

def cputs(string)
    puts "\033[1m#{string}\033[0m"
end

# get Puppet master name
def load_config
  master = Puppet.settings[:server]
  if master
    @classifier_url = "https://#{master}:4433/classifier-api"
    @rbac_url = "https://#{master}:4433/rbac-api"
    @puppet_ca_url = "https://#{master}:8140/puppet-ca"
    @puppetdb_url = "https://#{master}:8081/pdb"
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

def new_role(roles)
  load_config
  roles.each do |x|
    output = @api_setup.post("#{@rbac_url}/v1/roles", x.to_json)
    puts output.body
  end
end

def new_group(groups)
  load_config
  groups.each do |x|
    output = @api_setup.post("#{@rbac_url}/v1/groups", x.to_json)
    puts output.body
  end
end

def new_user(users)
  load_config
  users.each do |x|
    output = @api_setup.post("#{@rbac_url}/v1/users", x.to_json)
    puts output.body
  end
end

def get_users()
  load_config
  output = @api_setup.get("#{@rbac_url}/v1/users")
  output.body
end

def test_rbac()
  load_config
end

#new_role()
new_role(@aussie_roles)
#new_group(@aussie_groups)
new_user(@aussie_pses)
get_users()
