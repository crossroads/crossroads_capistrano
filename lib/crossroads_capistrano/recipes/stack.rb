load File.join(File.dirname(__FILE__), 'yum.rb')

# Installs minimal system software stack. Runs before deploy:cold

before "deploy:cold",  "stack:setup"

namespace :stack do
  desc "Setup operating system and rails environment"
  task :setup do
    yum.update
    yum.install({:base => yum_packages}, :stable ) if exists?(:yum_packages)
    gemrc.setup
    bundler.setup
    deploy.setup
    shared.setup
    config.setup
    db.config.setup if respond_to?(:db)
    shared.permissions
    netrc.setup     if needs_netrc?
    ssh_key.setup   if needs_ssh_key?
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
    if capture("ls ~/.netrc").strip == ""
      puts "\n ** == Configuring ~/.netrc ..."
      puts " **    (Enter 's' to skip this file.)\n\n"
      prompt_with_default("Netrc Machine",  :netrc_machine,  "svn.globalhand.org")
      if netrc_machine == "s"
        puts "\n ** ! Skipping ~/.netrc\n\n"
      else
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
    else
      puts "\n ** == ~/.netrc already exists!\n\n"
    end
  end
end

namespace :ssh_key do
  desc "Generate ssh key for adding to GitHub public keys, etc."
  task :setup do
    puts "\n    If capistrano stops here then paste the following key into GitHub and"
    puts   "    run \"cap deploy:cold\" again\n\n"
    run  "    if ! (ls $HOME/.ssh/id_rsa); then (ssh-keygen -N '' -t rsa -q -f $HOME/.ssh/id_rsa && cat $HOME/.ssh/id_rsa.pub) && exit 1; fi"
  end
end

