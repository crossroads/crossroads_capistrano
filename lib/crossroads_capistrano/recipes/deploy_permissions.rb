# For apps that are deployed with user permissions.
# ----------------------------------------------------------

# Fetch user from ~/.netrc or $USER.
set :user, if File.exist?("~/.netrc")
  File.open(`echo ~/.netrc`.strip, 'r').read[/login ([a-z_]+)/m, 1]
else
  `echo $USER`.strip
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
      sudo "chown -R #{httpd_user}:#{httpd_group} #{current_path}/"
      sudo "chown -R #{httpd_user}:#{httpd_group} #{deploy_to}/shared/"
      $apache_permissions = true
    end
  end

  desc "Set permissions on releases directory so old releases can be removed"
  task :release_permissions do
    run "if [ -d #{release_path}/ ]; then #{sudo} chown -R #{httpd_user}:#{httpd_group} #{release_path}/; fi"
    run "if [ -d #{release_path}/ ]; then #{sudo} chmod -R 755 #{release_path}/; fi"
  end
end

# Set user permissions before running each task, and apache permission when tasks finish.
(ARGV - %w(preview live)).each do |t|
  before t, "deploy:user_permissions"
  after  t, "deploy:apache_permissions"
end

before "deploy:restart", "deploy:apache_permissions"
before "deploy:cleanup", "deploy:release_permissions"

