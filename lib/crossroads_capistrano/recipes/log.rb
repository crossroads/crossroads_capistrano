namespace :log do
  namespace :tail do
    desc "Tail rails log file"
    task :rails, :roles => :app do
      run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
        puts "\n#{channel[:host]}: #{data}"
        break if stream == :err
      end
    end
    desc "Tail Apache access log file"
    task :access, :roles => :app do
      run "tail -f #{shared_path}/log/access_log" do |channel, stream, data|
        puts "\n#{channel[:host]}: #{data}"
        break if stream == :err
      end
    end
  end

  namespace :pull do
    desc "Pull rails log file to /tmp/#{rails_env}.log"
    task :rails, :roles => :app do
      run "gzip -c #{shared_path}/log/#{rails_env}.log > #{shared_path}/log/#{rails_env}.log.gz"
      `rm -f /tmp/#{rails_env}.log.gz`
      puts "Downloading #{shared_path}/log/#{rails_env}.log...\n"
      get_with_status "#{shared_path}/log/#{rails_env}.log.gz", "/tmp/#{rails_env}.log.gz", :via => :scp
      run "rm -f #{shared_path}/log/#{rails_env}.log.gz"
      `gzip -fd /tmp/#{rails_env}.log.gz`
      puts "File can be accessed at /tmp/#{rails_env}.log"
    end
  end

  desc "Symlink shared logs to /var/log/rails/<application>-<stage>"
  task :symlink_shared do
    # Creates /var/log/rails/<application>-<stage> and migrates any existing logs.
    run "if ! [ -d /var/log/rails/#{application}-#{stage} ]; then #{sudo} mkdir -p /var/log/rails/#{application}-#{stage} && #{sudo} mv #{shared_path}/log/* /var/log/rails/#{application}-#{stage}/; fi"
    sudo "rm -rf #{shared_path}/log && ln -fs /var/log/rails/#{application}-#{stage} #{shared_path}/log"
    sudo "chown -R #{httpd_user}:#{httpd_group} /var/log/rails/#{application}-#{stage}/"
  end

  desc "Setup logrotate file (Requires /usr/sbin/logrotate and config/logrotate.conf)"
  task :logrotate do
    run "if [ -f /usr/sbin/logrotate ] && [ -f #{current_path}/config/logrotate.conf ]; then sed -e 's,@LOG_PATH@,/var/log/rails/#{application}-#{stage},g' #{current_path}/config/logrotate.conf > /etc/logrotate.d/#{application}-#{stage}; fi"
  end

end

after "stack", "log:symlink_shared"

