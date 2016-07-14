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
  @master = master
  if master
    @classifier_url   = "https://#{master}:4433/classifier-api"
    @rbac_url         = "https://#{master}:4433/rbac-api"
    @puppet_ca_url    = "https://#{master}:8140/puppet-ca"
    @puppetdb_url     = "https://#{master}:8081/pdb"
    @puppet_url       = "https://#{master}:8140/puppet"
    @status_url       = "https://#{master}:8140/status"
    @orchestrator_url = "https://#{master}:8143/orchestrator"
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

#
# Test five

# Monkey patch some token support in
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

def test(description,expected_result = true)
  puts "Running: #{description}"
  begin
    val = yield if block_given?
  rescue => e
    puts e.to_s
  end
  if val == expected_result
    puts "  Passed."
  else
    puts "  Failed, result was #{val}, expected #{expected_result}"
  end
end

# Allow us to make calls as the classifier
auth_info = {
  'ca_certificate_path' => Puppet[:localcacert],
  'certificate_path'    => "/etc/puppetlabs/puppet/ssl/certs/pe-internal-classifier.pem",
  'private_key_path'    => "/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-classifier.pem",
}
@classifier_identity = PuppetHttps.new(auth_info)

require 'pry'
require 'pry-byebug'

# test 'When hitting environment_classes it should return japanese defaults', true do
#   files = JSON.parse(@classifier_identity.get("#{@puppet_url}/v3/environment_classes?environment=production").body)
#   files['files'].any? { |file|
#     file['classes'].any? { |cls|
#       (cls['name'] == 'utf_8' and cls['params'].any? { |param|
#         param['default_literal'] == 'こんにちは'
#       })
#     }
#   }
# end

test 'Node groups should respond with proper utf8 name' do
  result = JSON.parse(@api_setup.get_with_token("#{@classifier_url}/v1/groups").body)
  result.any? do |group|
    group['name'] == 'アプリケーション・グループ'
  end
end

test 'Node groups should respond with proper utf8 params' do
  result = JSON.parse(@api_setup.get_with_token("#{@classifier_url}/v1/groups").body)
  result.any? do |group|
    group['classes'].any? do |cls|
      cls[1].any? do |key, value|
        value == 'こんにちは'
      end
    end
  end
end

test 'Node groups should respond with proper utf8 rules' do
  result = JSON.parse(@api_setup.get_with_token("#{@classifier_url}/v1/groups").body)
  result.any? do |group|
    group['rule'].flatten.flatten.any? do |rule|
      rule == 'ウェブ_サーバ'
    end
  end
end

test 'Classes endpoint should properly list  and detect utf8 values' do
  result = JSON.parse(@api_setup.get_with_token("#{@classifier_url}/v1/classes").body)
  base_profile = result.select do |cls|
    cls['name'] == 'profile::base'
  end
  base_profile[0]['parameters']['utf_8_notify_string'] == "'こんにちは'"
end

test 'Classifier should classify node0.puppet.vm with role::base when pp_role ~ ウェブ_サーバ' do
  result = JSON.parse(@api_setup.post_with_token("#{@classifier_url}/v1/classified/nodes/node0.puppet.vm",{'fact' => {'pp_role' => 'ウェブ_サーバ'}}.to_json).body)
  result['classes'].any? do |name,params|
    name == 'role::base'
  end
end

test 'Classifier should not classify node0.puppet.vm with role::base when pp_role !~ ウェブ_サーバ', false do
  result = JSON.parse(@api_setup.post_with_token("#{@classifier_url}/v1/classified/nodes/node0.puppet.vm",{'fact' => {'pp_role' => 'ブ_サーバ_ウェブ'}}.to_json).body)
  result['classes'].any? do |name,params|
    name == 'role::base'
  end
end

test 'PuppetDB should return facts that contains UTF8 with no queries' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4?query=facts[] {}")).body)
  result.any? do |fact|
    fact['name'] == 'data_centre' and fact['value'] == '東京'
  end
end

test 'PuppetDB should return facts that contains UTF8 with a UTF8 query' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4?query=facts[] { name = \"データセンター\" and value = \"東京\" }")).body)
  result.count == 7
end

test 'PuppetDB should return facts that contains UTF8 with a UTF8 based modifier' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4?query=facts[value] { name = \"データセンター\" group by value }")).body)
  result == [{"value"=>"東京"}]
end

test 'PuppetDB should return facts that contains UTF8 with a UTF8 based in modifier THIS WILL FAIL DUE TO BUG PDB-2862' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4?query=facts[] { value in [\"東京\"] }")).body)
  result.count != 0
end

test 'PuppetDB should return facts that contains UTF8 with a UTF8 based function' do
  # Note that the function here isn't actually getting passed a UTF8 value. This is because it's not possible
  # to get PuppetDB to output data with unexpected keys. i.e. I can't get
  # { "データセンター" => "東京"}
  # As output to then pass into the function, the values coming out of the database are always in the value side i.e.
  # {
  #   "name"  => "データセンター",
  #   "value" => "東京"
  # }
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4?query=facts[count()] { value = \"東京\" }")).body)
  result.count > 0
end

test 'PuppetDB should return facts that contains UTF8 with a UTF8 based regex match' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4?query=facts[] { value ~ \"東.*\" }")).body)
  result.count > 0
end

test 'PuppetDB should return events that contains UTF8 data' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4/events?query=[\"=\",\"new_value\",\"こんにちは\"]")).body)
  result.count > 0
end

test 'PuppetDB should return aggregate event counts that contain UTF8 data' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@puppetdb_url}/query/v4/aggregate-event-counts?summarize_by=resource&query=[\"=\",\"new_value\",\"こんにちは\"]")).body)
  result[0]['total'] > 0
end

test 'Orchestrator should be able to list applications' do
  result = JSON.parse(@api_setup.get_with_token(URI.escape("#{@orchestrator_url}/v1/environments/production/instances")).body)
  result['items'].all? do |app|
    app['title'] == 'English' or app['title'] == 'ブランク'
  end
end

test 'Orchestrator should be able to run applications THIS WILL FAIL DUE TO PCP-494, it should pass when fixed.' do
  # Get all applications
  applications = JSON.parse(@api_setup.get_with_token(URI.escape("#{@orchestrator_url}/v1/environments/production/instances")).body)['items']
  results = []

  # Deploy each application
  applications.each do |application|
    deploy = JSON.parse(@api_setup.post_with_token(URI.escape("#{@orchestrator_url}/v1/command/deploy"),{
      'environment' => 'production',
      'target' => "#{application['type']}[#{application['title']}]",
    }.to_json).body)
    deploy_status = JSON.parse(@api_setup.get_with_token(deploy['job']['id']).body)
    sleep 1
    require 'pry'
    require 'pry-byebug'
    # Periodically check the status until it is done
    until deploy_status['status'].last['state'] == 'failed' or deploy_status['status'].last['state'] == 'finished' do
      sleep 1
      deploy_status = JSON.parse(@api_setup.get_with_token(deploy['job']['id']).body)
    end

    # Now get the reports
    reports = JSON.parse(@api_setup.get_with_token(deploy_status['report']['id']).body)['report']
    results << reports.any? do |report|
      report['events'].any? do |event|
        event['new_value'] == 'ブランク' or event['new_value'] == 'English'
      end
    end
  end
  results.all? # Check that they were all true
end
