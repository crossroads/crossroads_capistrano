#
# Capistrano recipe to generate a self-signed ssl certificate
#
# Requires :site_domain_name be defined.
#
# It also "sets us up the bomb"
#

require File.join(File.dirname(__FILE__), 'yum.rb')

namespace :ssl do

  desc "Generates a self-signed ssl certificate."
  task :generate do
    install_deps
    sudo "openssl genrsa -out /etc/pki/tls/private/#{site_domain_name}.key 2048"
    sudo "chown root:root /etc/pki/tls/private/#{site_domain_name}.key && chmod 640 /etc/pki/tls/private/#{site_domain_name}.key"
    sudo "openssl req -batch -new -key /etc/pki/tls/private/#{site_domain_name}.key -out /etc/pki/tls/certs/#{site_domain_name}.csr"
    sudo "openssl x509 -req -days 365 -in /etc/pki/tls/certs/#{site_domain_name}.csr -signkey /etc/pki/tls/private/#{site_domain_name}.key -out /etc/pki/tls/certs/#{site_domain_name}.crt"
    sudo "rm -f /etc/pki/tls/certs/#{site_domain_name}.csr"
  end

  task :install_deps do
    yum.install( {:base => %w(openssl openssl-devel)}, :stable )
  end

end
