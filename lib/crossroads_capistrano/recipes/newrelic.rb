require 'new_relic/recipes'

namespace :deploy do
  desc "Notify New Relic of the deployment"
  task :notify_newrelic, :except => { :no_release => true } do
    if stage.to_s == 'live'
      if File.exists?('config/newrelic.yml')
        if ARGV.include?("-n")
          puts "\n ** Dry run, not notifying New Relic.\n\n"
        else
          newrelic.notice_deployment
        end
      else
        puts "\n !! You need to set up 'config/newrelic.yml'.\n    You can copy the shared/config files from a server by running 'cap config:pull'.\n\n"
      end
    end
  end
end

after NotificationTasks, "deploy:notify_newrelic"

