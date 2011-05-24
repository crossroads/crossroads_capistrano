namespace :log do
  namespace :tail do
    desc "Tail Rails production log file"
    task :production, :roles => :app do
      run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
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
    desc "Pull production log file to /tmp/production.log"
    task :production, :roles => :app do
      run "gzip -c #{shared_path}/log/production.log > #{shared_path}/log/production.log.gz"
      `rm -f /tmp/production.log.gz`
      puts "Downloading #{shared_path}/log/production.log...\n"
      get_with_status "#{shared_path}/log/production.log.gz", "/tmp/production.log.gz", :via => :scp
      run "rm -f #{shared_path}/log/production.log.gz"
      `gzip -fd /tmp/production.log.gz`
      puts "File can be accessed at /tmp/production.log"
    end
  end

  desc "Symlink shared logs to /var/log/rails/<application>-<stage>"
  task :symlink_shared do
    # Creates /var/log/rails/<application>-<stage> and migrates any existing logs.
    run "if ! [ -d /var/log/rails/#{application}-#{stage} ]; then #{sudo} mkdir -p /var/log/rails/#{application}-#{stage} && #{sudo} mv #{shared_path}/log/* /var/log/rails/#{application}-#{stage}/; fi"
    sudo "rm -rf #{shared_path}/log && ln -fs /var/log/rails/#{application}-#{stage} #{shared_path}/log"
    sudo "chown -R #{httpd_user}:#{httpd_group} /var/log/rails/#{application}-#{stage}/"
  end
end

after "stack", "log:symlink_shared"

