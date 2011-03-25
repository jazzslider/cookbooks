#
# Cookbook Name:: infoblox-api
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "perl"

# Dependencies for the installation process
package "libcrypt-ssleay-perl"

execute "extract Infoblox module prior to installation" do
  cwd "/tmp"
  command "tar -xzf /tmp/Infoblox-#{node[:infoblox][:api][:version]}.tar.gz"
  action :nothing
end

remote_file "/tmp/Infoblox-#{node[:infoblox][:api][:version]}.tar.gz" do
  source "https://#{node[:infoblox][:ip_addr]}/api/dist/CPAN/authors/id/INFOBLOX/Infoblox-#{node[:infoblox][:api][:version]}.tar.gz"
  not_if "perl -mInfoblox -e ''"
  notifies :run, "execute[extract Infoblox module prior to installation]", :immediately
end

execute "install the Infoblox API" do
  cwd "/root"
  command "cpanp -i /tmp/Infoblox-#{node[:infoblox][:api][:version]}"
  not_if "perl -mInfoblox -e ''"
end
