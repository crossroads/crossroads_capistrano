namespace :log do
  desc "Tail production log file"
  task :tail, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
  namespace :pull do
    desc "Pull production log file to /tmp/production.log"
    task :production, :roles => :app do
      run "gzip -c #{shared_path}/log/production.log > #{shared_path}/log/production.log.gz"
      `rm -f /tmp/production.log.gz`
      download("#{shared_path}/log/production.log.gz", "/tmp/production.log.gz", :via => :scp)
      run "rm -f #{shared_path}/log/production.log.gz"
      `gzip -fd /tmp/production.log.gz`
      puts "File can be accessed at /tmp/production.log"
    end
  end
end

