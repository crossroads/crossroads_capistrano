# Faster deploy:notify_hoptoad (without extra rake task)
# Sends information about the deploy to Hoptoad.

namespace :deploy do
  desc "Notify Hoptoad of the deployment"
  task :notify_hoptoad, :except => { :no_release => true } do
    if ARGV.include?("-n")
      puts "\n ** Dry run, not notifying Hoptoad.\n\n"
    else
      require 'hoptoad_notifier'
      require File.join(rails_root,'config','initializers','hoptoad')
      require 'hoptoad_tasks'

      # Ignore HoptoadTasks output. Don't want to see the XML request.
      HoptoadTasks.module_eval do; def self.puts(str); true; end; end

      rails_env = fetch(:hoptoad_env, fetch(:rails_env, "production"))
      local_user = ENV['USER'] || ENV['USERNAME']

      puts %Q{
    * \033[0;32m== Notifying Hoptoad of Deploy\033[0m
        - \033[0;33mUser:\033[0m #{local_user}
        - \033[0;33mRails Environment:\033[0m #{rails_env}
        - \033[0;33mRevision:\033[1;37m #{current_revision[0,7]}\033[0m
        - \033[0;33mRepository:\033[0m #{repository}\n\n}

      HoptoadTasks.deploy(:rails_env      => rails_env,
                          :scm_revision   => current_revision,
                          :scm_repository => repository,
                          :local_username => local_user)

      puts "\n      ===== Notified."
    end
  end
end

namespace :hoptoad do
  desc "Test Hoptoad Notifier"
  task :test_error do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake hoptoad:test"
  end
end

after NotificationTasks, "deploy:notify_hoptoad"

