namespace :db do
  namespace :config do
    desc "Create shared/config/database.yml"
    task :setup do
      puts "\n ** == Configuring config/database.yml (mysql) ...\n\n"
      prompt_with_default("Database adapter", :db_adapter, "mysql")
      prompt_with_default("Database name", :db_name, "#{application}_#{stage}")
      prompt_with_default("Database username", :db_username, "#{application}_#{stage}")
      prompt_with_default("Database password", :db_password)
      prompt_with_default("Database host", :db_host, "localhost")
      prompt_with_default("Database port", :db_port, "3306")
      database_yml = <<-EOF
production:
  adapter: #{db_adapter}
  encoding: utf8
  database: #{db_name}
  username: #{db_username}
  password: #{db_password}
  host:     #{db_host}
  port:     #{db_port}
  pool:     10
  timeout:  5
EOF
    put database_yml, "#{shared_path}/config/database.yml"
    end
  end

  desc "Download production database to local machine"
  task :pull do
    prompt_with_default("Remote database name", :database_name, "#{application}_#{stage}")
    prompt_with_default("Overwrite local db? (y/n)", :overwrite, "y")
    if overwrite.to_s.downcase[0,1] == "y"
      prompt_with_default("Local role", :local_role, "root")
      prompt_with_default("Local db name", :local_db, "#{application}_development")
    end

    # Dump database
    sudo "mysqldump #{database_name} > /tmp/db_dump.sql", :hosts => first_db_host
    # Download dumped database
    get_with_status "/tmp/db_dump.sql", "tmp/#{application}_#{stage}_dump.sql", :via => :scp, :hosts => first_db_host
    # Delete dumped database from server
    sudo "rm -rf /tmp/db_dump.sql", :hosts => first_db_host
    if overwrite.to_s.downcase[0,1] == "y"
      # Import data
      puts "== Importing data to local database..."
      system "mysql -u #{local_role} #{local_db} < tmp/#{application}_#{stage}_dump.sql"
    end
  end
end

