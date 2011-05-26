# Faster deploy:notify_hoptoad (without extra rake task)
# Sends information about the deploy to Hoptoad.

namespace :deploy do
  desc "Notify Hoptoad of the deployment"
  task :notify_hoptoad, :except => { :no_release => true } do
    if ARGV.include?("-n")
      puts "\n ** Dry run, not notifying Hoptoad.\n\n"
    else
      begin
        require 'active_support/core_ext/string'
      rescue Exception
      end
      require 'hoptoad_notifier'
      require File.join(rails_root,'config','initializers','hoptoad')
      require 'hoptoad_tasks'

      # Format HoptoadTasks output nicely.
      HoptoadTasks.module_eval do; def self.puts(str); super " ** #{str}\n\n"; end; end

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
    end
  end
end

after NotificationTasks, "deploy:notify_hoptoad"

