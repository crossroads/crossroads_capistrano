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
      download("#{shared_path}/log/production.log.gz", "/tmp/production.log.gz", :via => :scp)  do |channel, name, received, total|
        print "\r   #{name}: #{(Float(received)/total*100).to_i}% complete..."
      end
      run "rm -f #{shared_path}/log/production.log.gz"
      `gzip -fd /tmp/production.log.gz`
      puts "File can be accessed at /tmp/production.log"
    end
  end
end

