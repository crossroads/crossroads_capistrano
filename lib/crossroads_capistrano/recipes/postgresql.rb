namespace :postgresql do
  task :symlink do
    sudo "ln -sf #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Start PostgreSQL"
  task :start, :roles => :db do
    send(run_method, "/etc/init.d/postgresql start")
  end

  desc "Stop PostgreSQL"
  task :stop, :roles => :db do
    send(run_method, "/etc/init.d/postgresql stop")
  end

  desc "Restart PostgreSQL"
  task :restart, :roles => :db do
    send(run_method, "/etc/init.d/postgresql restart")
  end

  desc "Reload PostgreSQL"
  task :reload, :roles => :db do
    send(run_method, "/etc/init.d/postgresql reload")
  end
end

namespace :db do
  desc "Download production database to local machine"
  task :pull do
    prompt_with_default("Database", :dbname, "#{application}_#{default_stage}")
    prompt_with_default("Database user", :username, "postgres")
    prompt_with_default("Local role", :local_role, "postgres")
    prompt_with_default("Overwrite local db? (y/n)", :overwrite, "y")
    host = find_servers(:roles => :db).map(&:to_s).first
    run "pg_dump -U #{username} #{dbname} > /tmp/dump.sql", :hosts => host
    get "/tmp/dump.sql", "tmp/dump.sql", :via => :scp, :hosts => host do |channel, name, received, total|
      print "\r#{name}: #{(Float(received)/total*100).to_i}% complete"
    end
    run "rm -rf /tmp/dump.sql", :hosts => host
    `sed -i s/stockit/#{local_role}/g tmp/dump.sql`
    # Import data.
    if overwrite.to_s.downcase[0,1] == "y"
      `psql -d stockit_development < tmp/dump.sql`
    end
  end
end


after "deploy:update_code", "postgresql:symlink"

