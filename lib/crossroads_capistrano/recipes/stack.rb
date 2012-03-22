load File.join(File.dirname(__FILE__), 'yum.rb')

# Installs minimal system software stack. Runs before deploy:cold

before "deploy:cold",  "stack:setup"

namespace :stack do
  desc "Setup operating system and rails environment"
  task :setup do
    package.update
    package.install
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
      run "rvmsudo gem install bundler"
    end
  end
end

# yum wrapper
namespace :package do

  desc "Installs yum packages required for the app"
  task :install do
    yum.install({:base => yum_packages}, :stable, :shell => 'sh') if exists?(:yum_packages)
  end

  desc "Updates all yum packages installed"
  task :update do
    yum.update :shell => 'sh'
  end

  desc "Takes a list of yum packages and determines if they need updating. This is useful for determining whether to apply security updates."
  task :list_installed_yum_packages do
    prompt_with_default("Enter comma seperated list of yum pacakges (e.g. qspice, lftp).\nIf you leave this blank then it will list all installed packages:", :packages, "")
    packages.gsub!(/,\s*/, "\\|")
    sudo "yum -C list | grep '#{packages}' | grep installed"
    puts "The packages listed above are installed on the system"
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
    if !remote_file_exists?("~/.netrc") || ARGV.include?("netrc:setup")
      puts "\n ** == Configuring ~/.netrc ..."
      puts " **    (Enter 's' to skip this file.)\n\n"
      prompt_with_default("Netrc Machine",  :netrc_machine,  "code.crossroads.org.hk")
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

