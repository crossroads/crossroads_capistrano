namespace :db do
  namespace :config do
    desc "Create shared/config/database.yml"
    task :setup do
      puts "\n ** == Configuring config/database.yml (postgres) ...\n\n"
      prompt_with_default("Database name", :db_name, "#{application}_#{stage}")
      prompt_with_default("Database username", :db_username, application)
      prompt_with_default("Database password", :db_password)
      prompt_with_default("Database host", :db_host, "localhost")
      prompt_with_default("Database port", :db_port, "5432")
      database_yml = <<-EOF
production:
  adapter: postgresql
  host: #{db_host}
  port: #{db_port}
  database: #{db_name}
  username: #{db_username}
  password: #{db_password}
  schema_search_path: public
  encoding: utf8
  template: template0
EOF
    put database_yml, "#{shared_path}/config/database.yml"
    end
  end

  desc "Download production database to local machine"
  task :pull do
    prompt_with_default("Database name", :dbname, "#{application}_#{stage}")
    prompt_with_default("Database user", :username, "postgres")
    prompt_with_default("Local role", :local_role, "postgres")
    prompt_with_default("Overwrite local development db? (y/n)", :overwrite, "y")

    # Dump database
    sudo "pg_dump -U #{username} #{dbname} > /tmp/dump.sql", :hosts => first_db_host
    # Download dumped database
    get_with_status "/tmp/db_dump.sql", "tmp/#{application}_#{stage}_dump.sql", :via => :scp, :hosts => first_db_host
    # Delete dumped database from server
    sudo "rm -rf /tmp/db_dump.sql", :hosts => first_db_host
    # Replace server db role with local role
    system("sed -i s/#{application}/#{local_role}/g tmp/#{application}_#{stage}_dump.sql")
    if overwrite.to_s.downcase[0,1] == "y"
      # Import data
      system("psql -d #{application}_development < tmp/#{application}_#{stage}_dump.sql")
    end
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

