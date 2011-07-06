#
# Adds passenger tasks to deploy stack
#
# Ensure the following variables are set in your deploy.rb
#   - set :ip_address, "127.0.0.1"
#   - set :site_domain_name, "www.example.com"
#   - set :passenger_version, "3.0.0"
#
# And that the following files exist:
#
# config/httpd-rails.conf
# config/passenger.conf
#

namespace :deploy do
  %w(start stop restart reload).each do |t|
    desc "#{t.capitalize} passenger using httpd"
    task t, :roles => :app, :except => { :no_release => true } do
      sudo "/etc/init.d/httpd #{t}"
    end
  end

  desc "Apache permissions (for passenger)"
  task :apache_permissions do
    unless $apache_permissions
      sudo "chown -R #{httpd_user}:#{httpd_group} #{current_path}/"
      sudo "chown -R #{httpd_user}:#{httpd_group} #{shared_path}/"
      $apache_permissions = true
    end
  end
end

namespace :passenger do
  desc "Install Passenger"
  task :install, :roles => :web do
    install_deps
    passenger_install_cmd = (exists?(:rvm_ruby_string) ? "rvmsudo " : "") << "passenger-install-apache2-module --auto" # sets up ruby wrapper correctly
    run "if ! (gem list | grep passenger | grep #{passenger_version}); then gem install passenger --no-rdoc --no-ri --version #{passenger_version} && #{passenger_install_cmd}; fi"
  end

  task :install_deps, :roles => :web do
    yum.install( {:base => %w(curl-devel httpd-devel apr-devel openssl-devel zlib-devel e2fsprogs-devel krb5-devel)}, :stable )
  end

  desc "Set up Apache and Passenger config files"
  task :config, :roles => :web do
    unless (exists?(:no_passenger_conf) && no_passenger_conf)
      # You can set the following paths from your deploy.rb file, if needed.
      set :httpd_site_conf_path, "/etc/httpd/sites-enabled/010-#{application}-#{stage}.conf" unless exists?(:httpd_site_conf_path)
      set :passenger_conf_path, "/etc/httpd/mods-enabled/passenger.conf" unless exists?(:passenger_conf_path)

      if exists?(:rvm_ruby_string)  # Deploying with RVM
        ruby_root      = "/usr/local/rvm/wrappers/#{rvm_ruby_string}/ruby"
        passenger_root = "/usr/local/rvm/gems/#{rvm_ruby_string}/gems/passenger-#{passenger_version}"
      else  # System Ruby
        ruby_root      = capture("which ruby").strip
        gem_path       = capture("ruby -r rubygems -e 'p Gem.path.detect{|p|p.include? \"/usr\"}'").strip.gsub('"','')
        passenger_root = "#{gem_path}/gems/passenger-#{passenger_version}"
      end
      # httpd conf
      sudo "cp -f #{release_path}/config/httpd-rails.conf #{httpd_site_conf_path}"
      sed httpd_site_conf_path, {"DEPLOY_TO"        => deploy_to,
                                 "IP_ADDR"          => ip_address,
                                 "SERVER_NAME"      => site_domain_name,
                                 "SITE_DOMAIN_NAME" => site_domain_name,
                                 "HTTP_PORT"        => http_port,
                                 "HTTPS_PORT"       => https_port}
      # passenger conf
      sudo "cp -f #{release_path}/config/passenger.conf #{passenger_conf_path}"
      sed passenger_conf_path,  {"PASSENGER_ROOT"   => passenger_root,
                                 "RUBY_ROOT"        => ruby_root}
    end
  end
end

before "deploy:cold",        "passenger:install"
after "deploy:update_code",  "passenger:config"
before "deploy:start",       "deploy:apache_permissions"
before "deploy:restart",     "deploy:apache_permissions"

