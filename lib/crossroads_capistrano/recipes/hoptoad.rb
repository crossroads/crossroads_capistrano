# Faster deploy:notify_hoptoad (without extra rake task)
# Sends information about the deploy to Hoptoad.

namespace :deploy do
  desc "Notify Hoptoad of the deployment"
  task :notify_hoptoad, :except => { :no_release => true } do
    require 'hoptoad_notifier'
    require 'config/initializers/hoptoad'
    require 'hoptoad_tasks'

    rails_env = fetch(:hoptoad_env, fetch(:rails_env, "production"))
    local_user = ENV['USER'] || ENV['USERNAME']

    puts %Q{
  * \033[0;32m== Notifying Hoptoad of Deploy\033[0m
      - \033[0;33mUser:\033[0m #{local_user}
      - \033[0;33mRails Environment:\033[0m #{rails_env}
      - \033[0;33mRevision:\033[0m #{current_revision}
      - \033[0;33mRepository:\033[0m #{repository}\n\n}

    HoptoadTasks.deploy(:rails_env      => rails_env,
                        :scm_revision   => current_revision,
                        :scm_repository => repository,
                        :local_username => local_user)

    puts "\n    Hoptoad Notification Complete.\n\n"
  end
end

after "deploy",            "deploy:notify_hoptoad"
after "deploy:migrations", "deploy:notify_hoptoad"

