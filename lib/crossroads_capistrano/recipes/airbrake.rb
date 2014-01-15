# Faster deploy:notify_airbrake (without extra rake task)
# Sends information about the deploy via Airbrake.

require 'airbrake'

namespace :airbrake do
  desc "Send deployment notification via Airbrake"
  task :notify_deployment, :except => { :no_release => true } do
    if ARGV.include?("-n")
      puts "\n ** Dry run, not notifying.\n\n"
    else
      #~ require 'airbrake'
      require File.join(rails_root,'config','initializers','airbrake')
      require 'airbrake_tasks'

      # Ignore AirbrakeTasks output. Don't want to see the XML request.
      AirbrakeTasks.module_eval do; def self.puts(str); true; end; end

      rails_env = fetch(:airbrake_env, fetch(:rails_env, "production"))
      local_user = ENV['USER'] || ENV['USERNAME']

      puts %Q{
    * \033[0;32m== Sending deployment notification via Airbrake\033[0m
        - \033[0;33mUser:\033[0m #{local_user}
        - \033[0;33mRails Environment:\033[0m #{rails_env}
        - \033[0;33mRevision:\033[1;37m #{current_revision[0,7]}\033[0m
        - \033[0;33mRepository:\033[0m #{repository}\n\n}

      AirbrakeTasks.deploy(:rails_env      => rails_env,
                           :scm_revision   => current_revision,
                           :scm_repository => repository,
                           :local_username => local_user)

      puts "      ===== Notified.\n\n"
    end
  end
end

namespace :airbrake do
  desc "Test Airbrake notifications"
  task :test_error do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake airbrake:test"
  end
end

after NotificationTasks, "airbrake:notify_deployed"
