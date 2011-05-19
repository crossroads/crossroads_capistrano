# For apps that are deployed with user permissions.
# ----------------------------------------------------------

# Our developers use different users on their local machines.
set :user, case sysuser = `echo $USER`.strip
when 'warp'  then 'bstillman'
when 'steve' then 'swkenworthy'
else sysuser
end

namespace :deploy do
  desc "Deploy permissions (give user access to everything)"
  task :user_permissions do
    sudo "chown -R #{user} #{deploy_to}"
    $apache_permissions = false
  end
  desc "Apache permissions (for passenger)"
  task :apache_permissions do
    unless $apache_permissions
      sudo "chown -R #{httpd_user}:#{httpd_grp} #{current_path}/"
      sudo "chown -R #{httpd_user}:#{httpd_grp} #{deploy_to}/shared/"
      $apache_permissions = true
    end
  end
end

# Set user permissions before running each task, and apache permission when tasks finish.
(ARGV - %w(preview live)).each do |t|
  before t, "deploy:user_permissions"
  after  t, "deploy:apache_permissions"
end

before "deploy:restart", "deploy:apache_permissions"

