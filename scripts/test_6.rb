#!/opt/puppetlabs/puppet/bin/ruby
require 'puppetclassify'
require 'puppet'

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

resource_manage('user','デイビッド',{'ensure' => 'present','home' => '/home/デイビッド'})
resource_manage('file','/home/デイビッド',{'ensure' => 'directory','owner' => 'デイビッド','group' => 'デイビッド', 'mode' => '0700'})
resource_manage('file','/home/デイビッド/.puppetlabs',{'ensure' => 'directory','owner' => 'デイビッド','group' => 'デイビッド', 'mode' => '0700'})
new_user({ 'login' => 'デイビッド','display_name' => 'デイビッド','email' => 'デイビッド@puppet.com','role_ids' => [1]}, '/root/.puppetlabs')
