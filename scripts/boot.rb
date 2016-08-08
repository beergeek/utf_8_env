#!/opt/puppetlabs/puppet/bin/ruby
require 'puppetclassify'
require 'puppet'

@private_key = <<-EOS
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEApjhnxCSNWVJJGoRKvrV00cMB8utFSxIlG87Hid2ViTQMgRAj
bDXWAlj9lMyiwU5XRUrCAjRJuw+oOcYxl6MQap8rgalc42DBmixbmlWFa/CV+qEn
D/RDY7jm0esAbuyybtkaIn4IIWSfNuiKi18UqCn54189fBWxzH6DgNnoawcqQya0
IFSoEqf+YZqr+KRJa4EJoDridgRzMaE7CHcT3HThGbYahJM/rLqb569RALHamZCC
q1zCYeUC+tkgtItvX1MiPuDwfb9DpDyS+Ktm/Jry2fQ6a5K0pWpulmBtlUH/b7IS
18RqPQ9zk8Y7k6k2ydv+OG3wb/gHVLT8oZR+tQIDAQABAoIBADpda/Ivc4J9pjWt
ZiF4zcAp3TFS803c3TLadK4wJCW9JPbcl9OTQ8YnQUNSZ4PA4lvuWBk2Cv2oDcXb
leZM16LYqQoqUfd1LgXYtYGHrgWswLz0gSbU+iS19DaZcdmBO1Y43ThnUKuJDW7W
UG+Hv1UdCCWSd6BubbQEaGCCI14Q4OeenmGbIzwBzjnlH2Xmteur0wYjmGT5nxoJ
42qD7Rm2OPsy6y5NDTJejMJDXASVBj1wQtmNTlnhGfzn4etNslav+srFhvwsqxFc
v43HGKb9VIzCW8IMVn51wXPb4b5sV6UBy7XdEyWrjjTrOpA5dXi2dQtRMP9qBiqJ
jks7vrECgYEA2m+1z3dCFkZgBiLyBIob+cF0GfBMxeKyYfiK5Y8/z6qTdFCAjVtD
q2q9GG0gBUJtvAb7AMlwsj+ozwTY7Dn9zFpjWn1PuIEerG7D4wtFMn9km/TD5YAc
51woUqMZIkLCqp/OkrrhRu+XjC0+DhWU48V4VIk1XRPCy78h+My9Q7cCgYEAws35
FLdiWJUXZaAeKQW3CV/lhm0nODPksGXi4J2q4Ljw7MrbU5EULd+Ek4ietiPM1P04
Ggwa4GVYU9gTtVsCEjeBc7ZZntk12N247tH1azL3d9huC6BNFGh+URBG1NdvjkoF
ZnxIie4fWmyF9WLNMmAlY81SVjZlI9w9s7msiPMCgYAl05SDcd6C5vr39RM+EACa
NpL5bvCMkB5d8uFysWTWfG5+hPZOBFDqnVhTo4oY/xDrr7XFxBx88aM0/lzmQ4Cc
48YyxGKKy+lY6PGJHsmD3iW5ECDgXFglBIODE/VlRnRZgcUPCce7NgBjaO5HGBup
eefFk+Em1iY0jEvAvwvDbwKBgBTd00xwyEwMzFDKcfCa+Bw89W0MzCKtDFYI0+CT
gvZHWSdEI3I0HCE9zAmxnK6N7ybxaM0Bdu+Ka4evoYzPjs08vNUUN01Ynvf36BNM
0ikFcJSZzk/Yf+kruDwerjemTADF1QZBUdPUee9JqJ+8UZaPzfF+0M8DTJomwUU7
IkwZAoGBAJhZYyuXhdJu4hO7KgvUAH29FibTmRceVHWqjH1TYVCDrmWvRQcRp0Mq
C4pqyV/fLR0ijCluO9/bDFWf1NKf3OFqFPpu84D0yVgKxINyVP32GWx6yP2keHsz
YUl+N0ChGemstrmAyRglzZUINLTLfjKRcZzFIoSEuaSRoqSSJB2R
-----END RSA PRIVATE KEY-----
EOS

@public_key = <<-EOS
-----BEGIN CERTIFICATE-----
MIIC2TCCAcGgAwIBAgIBATANBgkqhkiG9w0BAQUFADAAMCAXDTE2MDYyNjIzNTEz
NloYDzIwNjYwNjE0MjM1MTM2WjAAMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEApjhnxCSNWVJJGoRKvrV00cMB8utFSxIlG87Hid2ViTQMgRAjbDXWAlj9
lMyiwU5XRUrCAjRJuw+oOcYxl6MQap8rgalc42DBmixbmlWFa/CV+qEnD/RDY7jm
0esAbuyybtkaIn4IIWSfNuiKi18UqCn54189fBWxzH6DgNnoawcqQya0IFSoEqf+
YZqr+KRJa4EJoDridgRzMaE7CHcT3HThGbYahJM/rLqb569RALHamZCCq1zCYeUC
+tkgtItvX1MiPuDwfb9DpDyS+Ktm/Jry2fQ6a5K0pWpulmBtlUH/b7IS18RqPQ9z
k8Y7k6k2ydv+OG3wb/gHVLT8oZR+tQIDAQABo1wwWjAPBgNVHRMBAf8EBTADAQH/
MB0GA1UdDgQWBBTt2IMiH/4qn1Pz2PHPaB7o+VJdLTAoBgNVHSMEITAfgBTt2IMi
H/4qn1Pz2PHPaB7o+VJdLaEEpAIwAIIBATANBgkqhkiG9w0BAQUFAAOCAQEATtHc
Twa0D+v8nb+eta3cs+BdGsW7uZvOcwlVbD0JWtE45EaGHs448y+99e+5UeQi+Kp1
rRtVD+So2606BY29fyndE+BOgFndGZRznWeiBBUZ1mO/WRyJZEyLEHA9CBJLdZZ3
USQ+QkGQP2Zs1Lmx1sHOL2puiLZlNWhq5o8NJ5/13g7gwte4hYeXvrzID1I3cUrb
dwMPt6oidmx47ZSTNkocl00+1SSdt74yB+FFbvSoaiE5L4fzoFsYd7LYKmen9TsH
CVm0Fnw2jKopBx8QgdMRlaz6gAuIFaWMCSXLh2tzokJxzcIreKjkKbe6pSbLDLGk
niYGTE2SC9pmrPAurw==
-----END CERTIFICATE-----
EOS

@hiera_config = <<-EOS
---
:backends:
  - yaml
  - json
  - eyaml
:hierarchy:
  - "%{::trusted.certname}"
  - common

:yaml:
  :datadir: /etc/puppetlabs/code/environments/%{environment}/hieradata
:json:
  :datadir: /etc/puppetlabs/code/environments/%{environment}/hieradata
:eyaml:
  :datadir: /etc/puppetlabs/code/environments/%{environment}/hieradata
  :pkcs7_private_key: /etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem
  :pkcs7_public_key: /etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem
EOS

def cputs(string)
  puts "\033[1m#{string}\033[0m"
end

# Have puppet parse its config so we can call its settings
Puppet.initialize_settings

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

def load_api_config
  master = Puppet.settings[:server]
  @master = master
  if master
    @rbac_url = "https://#{master}:4433/rbac-api"
    @cm_url   = "https://#{master}:8170/code-manager"
    @fs_url   = "https://#{master}:8140/file-sync"
    auth_info = {
      'ca_certificate_path' => Puppet[:localcacert],
      'certificate_path'    => Puppet[:hostcert],
      'private_key_path'    => Puppet[:hostprivkey],
      'read_timeout'        => 600
    }
    unless @api_setup
      @api_setup = PuppetHttps.new(auth_info)
    end
  else
    cputs "No master!"
  end
end

def new_user(user, token_dir)
  load_api_config
  output = @api_setup.post("#{@rbac_url}/v1/users", user.to_json)
  if output.code.to_i <= 400
    reset_user_password(output['location'].split('/').last, user['login'], token_dir)
  elsif output.code.to_i == 409
    #retrieve the ID for the user here and reset password as per normal
  else
    raise Puppet::Error, "Failed to create new user: #{output.code} #{output.body}"
  end
end

def reset_user_password(user_id, user_login, token_dir)
  load_api_config
  reset_token = @api_setup.post("#{@rbac_url}/v1/users/#{user_id}/password/reset")
  if reset_token.code.to_i <= 400
    # yes I know this is not good programming practise, but this is me giving a shit right now.......
    password_reset = @api_setup.post("#{@rbac_url}/v1/auth/reset", { 'token' => reset_token.body, 'password' => 'モンスタートラック'}.to_json)
    if password_reset.code.to_i <= 400
      token = new_token({'login' => user_login, 'password' => 'モンスタートラック', 'lifetime' => '99d'}, token_dir)
    else
      raise Puppet::Error, "Failed to reset password: #{password_reset.code} #{password_reset.body}"
    end
  else
    raise Puppet::Error, "Failed to reset password: #{reset_token.code} #{reset_token.body}"
  end
end

def new_token(login, token_dir = nil)
  load_api_config
  # https://tickets.puppetlabs.com/browse/PE-13331 issue
  output = @api_setup.post("#{@rbac_url}/v1/auth/token", login.to_json)
  if output.code.to_i <= 400
    if token_dir
      Dir.mkdir(token_dir)
      f = open("#{token_dir}/token", 'w')
      f.write(JSON.parse(output.body)['token'])
      f.close
    end
  else
    raise Puppet::Error, "Failed to create new user: #{output.code} #{output.body}"
  end
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

# Add parent group as PE Infrasture so we can steal the params
# from there that the default install lays down
def create_group(group_name,group_uuid,classes = {},rule_term,parent_group)
  load_classifier
  @classifier.update_classes.update
  groups = @classifier.groups
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
  test_class('role::base')
  web_group = {
    'role::base' => {
      'ensure_utf_8_files'    => false,
      'ensure_utf_8_group'    => false,
      'ensure_utf_8_host'     => false,
      'ensure_utf_8_users'    => false,
      'ensure_utf_8_concat'   => false,
      'ensure_utf_8_static'   => false,
      'ensure_utf_8_nrp'      => false,
      'ensure_utf_8_registry' => false,
      'utf_8_notify_string'   => 'こんにちは',
    }
  }

  app_group = {
    'role::base' => {}
  }

  db_group = {
    'role::base' => {}
  }

  controller_group = {
    'puppet_enterprise::profile::controller' => {}
  }
  #Web Group
  create_group("ウェブ・グループ",'937f05eb-8185-4517-a609-3e64d05191c2',web_group,["or",["=",["trusted","extensions","pp_role"],"ウェブ_サーバ"],["~",["fact","pp_role"],"ウェブ_サーバ"]],"All Nodes")
  #Application Group
  create_group("アプリケーション・グループ",'937f05eb-8185-4517-a609-3e64d05191c1',app_group,["or",["=",["trusted","extensions","pp_role"],"アプリ_サーバ"],["~",["fact","pp_role"],"アプリ_サーバ"]],'All Nodes')
  #Databse Group
  create_group("データベース・グループ",'937f05eb-8185-4517-a609-3e64d05191ca',db_group,["and",["=",["trusted","extensions","pp_role"],"db_サーバ"],["~",["fact","pp_role"],"db_サーバ"]],'All Nodes')
  create_group('Controller','937f05eb-8185-4517-a609-3e64d05191c7',controller_group,["or",["~",["fact","clientcert"],"node2"]],'All Nodes')
end

def change_classification()
  cputs "Update Node Groups"
  master_rule = ["and",["=","name","master.puppet.vm"]]
  master_classes = {
    'pe_repo' => {},
    'pe_repo::platform::el_7_x86_64' => {},
    'pe_repo::platform::el_6_x86_64' => {},
    'pe_repo::platform::ubuntu_1604_amd64' => {},
    'pe_repo::platform::debian_8_amd64' => {},
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
  @classifier.update_classes.update
  groups = @classifier.groups
  pe_group = groups.get_groups.select { |group| group['name'] == "#{node_group}"}

  if classes
    group_hash = pe_group.first.merge({"classes" => classes})
    groups.update_group(group_hash)
  end
  group_hash = pe_group.first.merge({ "rule" => rule})

  groups.update_group(group_hash)
end

def resource_manage(resource_type, resource_name, cmd_hash)
  begin
    cputs "Managing resource #{resource_name}"
    x = ::Puppet::Resource.new(resource_type, resource_name, :parameters => cmd_hash)
    result, report = ::Puppet::Resource.indirection.save(x)
    report.finalize_report
    if report.exit_status == 4
      raise "ERROR: Could not manage resource of #{resource_type} with the title #{resource_name}: #{report.exit_status}"
    end
  end
end

def deploy_code
  cputs "Deploying code"
  load_api_config
  response = JSON.parse(@api_setup.post_with_token("#{@cm_url}/v1/deploys",{"deploy-all" => true, "wait" => true}.to_json).body)
  response.each do |x|
    if x['status'] != 'complete'
      raise Puppet::Error, "Code deployment failed, #{response.code} #{response.body}"
    end
  end
end

def commit_code
  cputs "Commiting code"
  load_api_config
  response = JSON.parse(@api_setup.post_with_token("#{@fs_url}/v1/commit",{"commit-all" => true}.to_json).body)
  if response['puppet-code']['status'] != 'ok'
    raise Puppet::Error, "Code deployment failed, #{response['puppet-code']['status']}"
  end
end

def test_class(class_name)
  load_classifier
  class_found = false
  while class_found == false do
    @classifier.update_classes.update
    response = JSON.parse(@api_setup.get_with_token(URI.escape("#{@classifier_url}/v1/environments/production/classes/#{class_name}")).body)
    if response['name'] == class_name
      class_found = true
      cputs "Found #{class_name} in NC registry"
    else
      cputs "#{class_name} not in NC registry as yet"
      commit_code
      sleep(30)
    end
  end
end

#config_r10k('https://github.com/beergeek/utf_8_test.git')
resource_manage('file','/etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem',{'ensure' => 'file','owner' => 'pe-puppet','group' => 'pe-puppet', 'mode' => '0400','content' => "#{@private_key}" })
resource_manage('file','/etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem',{'ensure' => 'file','owner' => 'pe-puppet','group' => 'pe-puppet', 'mode' => '0644','content' => "#{@public_key}" })
resource_manage('file','/etc/puppetlabs/puppet/hiera.yaml',{'ensure' => 'file','owner' => 'root','group' => 'root', 'mode' => '0644','content' => "#{@hiera_config}" })
new_user({ 'login' => 'ジョー','display_name' => 'ジョー','email' => 'ジョー@puppet.com','role_ids' => [1]}, '/root/.puppetlabs')
deploy_code
commit_code
update_master('PE PuppetDB',{ 'puppet_enterprise::profile::puppetdb' => { 'whitelisted_certnames' => ['node1.puppet.vm','node2.puppet.vm'] }})
test_class('role::mom_server')
test_class('utf_8')
new_groups()
change_classification()
