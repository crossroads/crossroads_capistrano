namespace :newrelic do
  task :default do
    newrelic.yml
  end

  desc "Copy newrelic.yml"
  task :yml do
    run "ln -sf #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
  end
end

before "deploy:symlink", "newrelic:yml"

