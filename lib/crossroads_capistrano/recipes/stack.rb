require File.expand_path('../yum', __FILE__)

# Installs minimal system software stack. Runs before "cap deploy:cold"

namespace :stack do
  desc "Setup operating system and rails environment"
  task :default do
    yum.update
    yum.install( {:base => packages_for_project}, :stable ) if defined?(packages_for_project)
    install.bundler
    deploy.setup
    shared.setup
    shared.permissions
  end
  namespace :install do
    desc "Install Bundler"
    task :bundler do
      run "gem install bundler --no-rdoc --no-ri"
    end
  end
end

namespace 'shared' do
  # This task can be extended by the application via an :after hook.
  desc "Setup shared directory"
  task :setup do
    sudo "mkdir -p #{deploy_to}/shared/config"
  end

  desc "Set permissions on shared directory"
  task :permissions do
    sudo "chown -R #{httpd_user}:#{httpd_group} #{deploy_to}/shared/"
    sudo "chmod -R 755 #{deploy_to}/shared/"
  end
end

namespace :deploy do
  desc "Check for project dependencies"
  task :check_dependencies, :roles => :db, :only => { :primary => true } do
    sudo "cd #{current_path} && RAILS_ENV=production rake check_dependencies"
  end
end

before "deploy:cold",  "stack"
after  "deploy:check", "deploy:check_dependencies"

