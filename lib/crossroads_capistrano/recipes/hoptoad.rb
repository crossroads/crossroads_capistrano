# Faster deploy:notify_hoptoad (without extra rake task)
# Sends information about the deploy to Hoptoad.

namespace :deploy do
  desc "Notify Hoptoad of the deployment"
  task :notify_hoptoad, :except => { :no_release => true } do
    require 'hoptoad_notifier'
    require File.join(Rails.root, 'config', 'initializers', 'hoptoad')
    require 'hoptoad_tasks'

    rails_env = fetch(:hoptoad_env, fetch(:rails_env, "production"))
    local_user = ENV['USER'] || ENV['USERNAME']

    puts "Notifying Hoptoad of Deploy (#{local_user}, #{rails_env}, #{current_revision}, #{repository})"

    HoptoadTasks.deploy(:rails_env      => rails_env,
                        :scm_revision   => current_revision,
                        :scm_repository => repository,
                        :local_username => local_user)

    puts "Hoptoad Notification Complete."
  end
end

after "deploy",            "deploy:notify_hoptoad"
after "deploy:migrations", "deploy:notify_hoptoad"

