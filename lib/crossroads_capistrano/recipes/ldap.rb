namespace :ldap do
  desc "Create the LDAP configuration file"
  task :config do
    prompt_with_default("LDAP host", :ldap_host, "")
    prompt_with_default("LDAP domain", :ldap_domain, "")
    prompt_with_default("LDAP username", :ldap_bind_username, "")
    prompt_with_default("LDAP password", :ldap_bind_password, "")
    prompt_with_default("LDAP search base", :ldap_base_dn, "")
    prompt_with_default("LDAP port", :ldap_port, "389")
    ldap_yml = <<-EOF
host: #{ldap_host}
port: #{ldap_port}
domain: #{ldap_domain}
base: #{ldap_base_dn}
username: #{ldap_bind_username}
password: #{ldap_bind_password}
    EOF

    put ldap_yml, "/tmp/ldap.yml"
    sudo "mv /tmp/ldap.yml #{shared_path}/config/ldap.yml"
  end

  task :symlink do
    sudo "ln -sf #{shared_path}/config/ldap.yml #{release_path}/config/ldap.yml"
  end

end
