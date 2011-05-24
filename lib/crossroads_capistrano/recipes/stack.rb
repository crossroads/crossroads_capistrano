load File.join(File.dirname(__FILE__), 'yum.rb')

# Installs minimal system software stack. Runs before deploy:cold

before "deploy:cold",  "stack:setup"

namespace :stack do
  desc "Setup operating system and rails environment"
  task :setup do
    yum.update
    yum.install({:base => yum_packages}, :stable ) if respond_to?(:yum_packages)
    gemrc.setup
    bundler.setup
    deploy.setup
    shared.setup
    config.setup
    db.config.setup
    netrc.setup if needs_netrc
    shared.permissions
  end
  namespace :bundler do
    desc "Install Bundler"
    task :setup do
      run "gem install bundler"
    end
  end
end

namespace :shared do
  # This task can be extended by the application via an :after hook.
  desc "Setup shared directory"
  task :setup do
    sudo "mkdir -p #{shared_path}/config"
  end

  desc "Set permissions on shared directory"
  task :permissions do
    sudo "chown -R #{httpd_user}:#{httpd_group} #{shared_path}/"
    sudo "chmod -R 755 #{shared_path}/"
  end
end

namespace :gemrc do
  desc "Setup ~/.gemrc file to avoid rdoc and ri generation"
  task :setup do
    puts "\n ** == Configuring ~/.gemrc ...\n\n"
    home_dir = capture("#{sudo} echo ~").strip
    put "gem: --no-ri --no-rdoc", "#{home_dir}/.gemrc"
  end
end

namespace :netrc do
  desc "Setup ~/.netrc file for internal git https auth"
  task :setup do
    puts "\n ** == Configuring ~/.netrc ...\n\n"
    prompt_with_default("Netrc Machine",  :netrc_machine,  "svn.globalhand.org")
    prompt_with_default("Netrc Login",    :netrc_login,    "")
    prompt_with_default("Netrc Password", :netrc_password, "")
    netrc = <<-EOF
machine #{netrc_machine}
login #{netrc_login}
password #{netrc_password}
EOF
    home_dir = capture("#{sudo} echo ~").strip
    put netrc, "#{home_dir}/.netrc"
  end
end

