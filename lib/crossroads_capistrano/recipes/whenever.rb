#
# Updates the crontab using wheneverize
#

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{current_path} && bundle exec whenever --update-crontab #{application}"
  end
end

after "deploy:symlink", "deploy:update_crontab"

