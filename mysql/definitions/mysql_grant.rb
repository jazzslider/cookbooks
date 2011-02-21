define :mysql_grant, :action => :create, :database => nil, :user => nil, :domain => "%", :password => nil, :privileges => "ALL" do
  include_recipe "mysql::server"
  include_recipe "mysql::client"

  case node[:platform]
  when "debian", "ubuntu"
    mysql_binary = "/usr/bin/mysql"
  else
    log("The mysql_grant definition is only available for Ubuntu systems at this time.") { level :fatal }
    raise "Precondition failed; the mysql_grant definition is only available for Ubuntu systems at this time."
  end

  if params[:database] == nil then
    log("The mysql_grant definition requires a database name.") { level :fatal }
    raise "Missing database argument for mysql_grant definition."
  end

  if params[:user] == nil then
    params[:user] = params[:database]
  end

  case params[:action]
  when :create
    case params[:password]
    when nil
      grant_command = "#{mysql_binary} -u root -p#{node[:mysql][:server_root_password]} -e \"GRANT #{params[:privileges]} ON #{params[:database]}.* TO '#{params[:user]}'@'#{params[:domain]}'; FLUSH PRIVILEGES;\""
    else
      grant_command = "#{mysql_binary} -u root -p#{node[:mysql][:server_root_password]} -e \"GRANT #{params[:privileges]} ON #{params[:database]}.* TO '#{params[:user]}'@'#{params[:domain]}' IDENTIFIED BY '#{params[:password]}'; FLUSH PRIVILEGES;\""
    end

    execute grant_command
    # TODO execution conditions?
  when :drop
    log "mysql_grant action does not yet support dropping grants; grant remains in place"
  else
    log "mysql_grant action #{params[:action]} not recognized."
  end
end
