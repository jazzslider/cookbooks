define :mysql_database, :action => :create do
  include_recipe "mysql::server"
  include_recipe "mysql::client"

  case node[:platform]
  when "debian", "ubuntu"
    mysqladmin_binary = "/usr/bin/mysqladmin"
  else
    log("The mysql_database definition is only available for Ubuntu systems at this time.") { level :fatal }
    raise "Precondition failed; the mysql_database definition is only available for Ubuntu systems at this time."
  end

  if params[:action] == :create then
    execute "create #{params[:name]} database" do
      command "#{mysqladmin_binary} -u root -p#{node[:mysql][:server_root_password]} create #{params[:name]}"
      not_if do
        m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
        m.list_dbs.include?(params[:name])
      end
    end
  elsif params[:action] == :drop then
    execute "drop #{params[:name]} database" do
      command "#{mysqladmin_binary} -u root -p#{node[:mysql][:server_root_password]} drop #{params[:name]}"
      only_if do
        m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
        m.list_dbs.include?(params[:name])
      end
    end
  else
    log "MySQL Database action #{params[:action]} not recognized."
  end
end
