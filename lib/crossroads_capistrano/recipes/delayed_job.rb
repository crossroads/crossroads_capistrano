namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec ./script/delayed_job stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec ./script/delayed_job start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    # We've found stop|start to be more reliable than restart
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec ./script/delayed_job stop"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec ./script/delayed_job start"
  end

  desc "delayed_job status"
  task :status, :roles => :app do
    run "ps aux | grep 'delayed_job'"
  end
end
