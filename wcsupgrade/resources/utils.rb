attribute :repository,		:kind_of => String,     :default => nil
attribute :distribPattern,	:kind_of => String,     :default => nil
attribute :updiHome,		:kind_of => String,     :default => nil
attribute :productHome,		:kind_of => String,     :default => nil
attribute :productUser,		:kind_of => String,     :default => nil
attribute :productGroup,	:kind_of => String,     :default => nil
attribute :distribList,		:kind_of => String,     :default => nil
attribute :execScript,		:kind_of => String,     :default => nil
attribute :spaceLimitGB,	:kind_of => Fixnum,	:default => 20
attribute :backupLocation,	:kind_of => String,     :default => nil
attribute :backupName,		:kind_of => String,     :default => nil
attribute :logFile,		:kind_of => String,     :default => "/tmp/iim.log"


actions :check_free_space
actions :execit
actions :version
default_action :version



action :check_free_space do
	free = node['filesystem2']['by_mountpoint']['/usr/opt/app']['kb_available'].to_i/1024/1024
	raise "not enough free space [ #{free} ]" if free < new_resource.spaceLimitGB
end


action :execit do
        raise "user was not provided" if new_resource.productUser.nil?
        raise "group was not provided" if new_resource.productGroup.nil?
        raise "script to execute was not provided" if new_resource.execScript.nil?
        raise "script execute directory was not provided" if new_resource.productHome.nil?

        raise "Invalid charachters found in install_command. Valid charachters are a-z, A-Z, 0-9, '-', '\\' and whitespace" unless new_resource.execScript =~ /[0-9|a-z|A-Z|\s|\\|\-]*/

        doit = Mixlib::ShellOut.new(new_resource.execScript, :user => new_resource.productUser, :group => new_resource.productGroup, :cwd => new_resource.productHome)
        puts " " + doit.stdout
        doit.live_stdout = $stdout
        doit.run_command
        puts doit.stderr
        doit.error!
end

action :backup do
	raise "product home directory was not provided" if new_resource.productHome.nil?
	raise "product owner user was not provided" if new_resource.productUser.nil?
	raise "product owner group was not provided" if new_resource.productGroup.nil?
	raise "place to keep was not provided" if new_resource.backupLocation.nil?
	raise "backup name was not provided" if new_resource.backupName.nil?
	raise "there is already backup with such name #{new_resource.backupLocation}/#{new_resource.backupName}.tar.gz" if ::File.exists?("#{new_resource.backupLocation}/#{new_resource.backupName}.tar.gz")

	execute 'tar' do
                command "tar -czpf #{new_resource.backupLocation}/#{new_resource.backupName}.tar.gz #{new_resource.productHome}"
                cwd     "#{new_resource.productHome}/.."
		user	new_resource.productUser
		group	new_resource.productGroup
        end

end


action :version do
        raise "product home directory was not provided" if new_resource.productHome.nil?
        raise "product owner user was not provided" if new_resource.productUser.nil?

	install_command = "#{new_resource.productHome}/bin/versionInfo.sh"

	doit = Mixlib::ShellOut.new(install_command, :user => new_resource.productUser, :cwd => new_resource.productHome)
	puts " " + doit.stdout
	doit.live_stdout = $stdout
	doit.run_command
	puts doit.stderr
	doit.error!
end
