attribute :repository,	:kind_of => String,     :default => nil
attribute :updiVersion,	:kind_of => String,     :default => nil
attribute :updiHome,	:kind_of => String,     :default => nil
attribute :logFile,	:kind_of => String,     :default => "/tmp/iim.log"


actions :install
actions :version
default_action :install


action :install do
	raise "repository was not provided" if new_resource.repository.nil?
	raise "updi version was not provided" if new_resource.updiVersion.nil?
        raise "installation directory was not provided" if new_resource.updiHome.nil?

	updiUser = node['updi']['wcs']['user']

        install_command = "echo updiUser new_resource.repository new_resource.updiVersion new_resource.updiHome"
        raise "Invalid charachters found in install_command. Valid charachters are a-z, A-Z, 0-9, '-', '\\' and whitespace" unless install_command =~ /[0-9|a-z|A-Z|\s|\\|\-]*/

        doit = Mixlib::ShellOut.new(install_command, :user => updiUser, :cwd => new_resource.repository)
        puts " " + doit.stdout
        doit.live_stdout = $stdout
        doit.run_command
        puts doit.stderr
        doit.error!
end


action :version do
        raise "installation directory was not provided" if new_resource.updiHome.nil?

	updiUser = node['updi']['wcs']['user']

	install_command = "#{new_resource.updiHome}/bin/versionInfo.sh"

	doit = Mixlib::ShellOut.new(install_command, :user => updiUser, :cwd => new_resource.updiHome)
	puts " " + doit.stdout
	doit.live_stdout = $stdout
	doit.run_command
	puts doit.stderr
	doit.error!
end
