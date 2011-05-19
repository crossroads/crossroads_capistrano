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
end

namespace :passenger do
  desc "Install Passenger"
  task :install, :roles => :web do
    install_deps
    run "if ! (gem list | grep passenger | grep #{passenger_version}); then gem install passenger --no-rdoc --no-ri --version #{passenger_version} && passenger-install-apache2-module --auto; fi"
    run "rvm wrapper #{rvm_ruby_string} passenger" if defined?(:rvm_ruby_string) # sets up wrapper for passenger so it can find bundler etc...
  end

  task :install_deps, :roles => :web do
    yum.install( {:base => %w(curl-devel httpd-devel apr-devel)}, :stable )
  end

  desc "Apache config files: uses special variables @DEPLOY_TO@ @IP_ADDR@ @SERVER_NAME@ @PASSENGER_ROOT@ @RUBY_ROOT@"
  task :config, :roles => :web do
    sudo "bash -c \"sed -e 's,@DEPLOY_TO@,#{deploy_to},g' -e 's,@IP_ADDR@,#{ip_address},g' -e 's,@SERVER_NAME@,#{site_domain_name},g' #{release_path}/config/httpd-rails.conf > /etc/httpd/sites-enabled/010-#{application}-#{stage}.conf\""

    if respond_to?(:rvm_ruby_string)  # Deploying with RVM
      ruby_root = "/usr/local/rvm/wrappers/#{rvm_ruby_string}/ruby"
      passenger_root = "/usr/local/rvm/gems/#{rvm_ruby_string}/gems/passenger-#{passenger_version}"
    else  # System Ruby
      ruby_root = capture("which ruby")
      passenger_root = capture("pass_path=`gem which phusion_passenger` && echo ${pass_path%/lib/phusion_passenger.rb}")
    end
    sed args = "-e 's%@PASSENGER_ROOT@%#{passenger_root.strip}%g' -e 's%@RUBY_ROOT@%#{ruby_root.strip}%g'"

    sudo "bash -c \"sed #{sed_args} #{release_path}/config/passenger.conf > /etc/httpd/mods-enabled/passenger.conf\""
  end
end

before "deploy:cold",        "passenger:install"
after  "deploy:update_code", "passenger:config"

