#
# Updates the crontab using wheneverize
#

namespace :whenever do
  desc "Update the crontab file"
  task :update, :roles => :db do
    run "cd #{current_path} && bundle exec whenever --update-crontab #{application}"
  end
  desc "Clear the crontab file"
  task :clear, :roles => :db do
    run "cd #{current_path} && bundle exec whenever --clear-crontab #{application}"
  end
end

after "deploy:symlink", "whenever:update"

