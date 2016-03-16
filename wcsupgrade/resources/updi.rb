attribute :repository,		:kind_of => String,     :default => nil
attribute :distribPattern,	:kind_of => String,     :default => nil
attribute :updiHome,		:kind_of => String,     :default => nil
attribute :productHome,		:kind_of => String,     :default => nil
attribute :productUser,		:kind_of => String,     :default => nil
attribute :productGroup,	:kind_of => String,     :default => nil
attribute :distribList,		:kind_of => String,     :default => nil
attribute :logFile,		:kind_of => String,     :default => "/tmp/iim.log"

distrTmp = "updi_src_tmp"


actions :prepare
actions :clean
actions :install
actions :prepare_for_apar
actions :update_product
actions :version
default_action :install


action :prepare do
	raise "repository was not provided" if new_resource.repository.nil?
	raise "updi distribPattern was not provided" if new_resource.distribPattern.nil?
        raise "product owner user was not provided" if new_resource.productUser.nil?
        raise "product owner group was not provided" if new_resource.productGroup.nil?

	distrib = "#{new_resource.repository}/#{new_resource.distribPattern}"
	execute 'unzip' do
		command	"unzip -q distrib #{new_resource.repository}/#{distrTmp}"
		cwd	new_resource.repository
		not_if	{ Dir.exists?("#{new_resource.repository}/#{distrTmp}") }
	end
	#zipfile distrib do
	#	into	"#{new_resource.repository}/#{distrTmp}"
	#	action	:extract
	#end

	directory "#{new_resource.repository}/#{distrTmp}" do
		mode		0755
		owner		new_resource.productUser
		group		new_resource.productGroup
		recursive       true
	end

end


action :clean do
	raise "repository was not provided" if new_resource.repository.nil?

	directory "#{new_resource.repository}/#{distrTmp}" do
		recursive       true
		action		:delete
	end

end


action :install do
	raise "repository was not provided" if new_resource.repository.nil?
        raise "product home directory was not provided" if new_resource.productHome.nil?
        raise "product owner user was not provided" if new_resource.productUser.nil?
        raise "product owner group was not provided" if new_resource.productGroup.nil?

        install_command = "UpdateInstaller/install -OPT silentInstallLicenseAcceptance='true' -OPT disableOSPrereqChecking='true' -OPT allowNonRootSilentInstall='true' -OPT installLocation='#{new_resource.productHome}' -silent"
        raise "Invalid charachters found in install_command. Valid charachters are a-z, A-Z, 0-9, '-', '\\' and whitespace" unless install_command =~ /[0-9|a-z|A-Z|\s|\\|\-]*/

        doit = Mixlib::ShellOut.new(install_command, :user => new_resource.productUser, :group => new_resource.productGroup, :cwd => "#{new_resource.repository}/#{distrTmp}")
        puts " " + doit.stdout
        doit.live_stdout = $stdout
        doit.run_command
        puts doit.stderr
        doit.error!
end


action :prepare_for_apar do
	raise "product home directory was not provided" if new_resource.productHome.nil?

	execute 'check_if_product_running' do
		command	"ps -aux | grep #{new_resource.productHome} | grep -v 'grep'"
		returns	1
	end
end


action :update_product do
        raise "updi home directory was not provided" if new_resource.updiHome.nil?
        raise "product home directory was not provided" if new_resource.productHome.nil?
        raise "product owner user was not provided" if new_resource.productUser.nil?
        raise "product owner group was not provided" if new_resource.productGroup.nil?
        raise "distrib lists was not provided" if new_resource.distribList.nil?

	install_command = "#{new_resource.updiHome}/update.sh -OPT checkFilePermissions='true' -W maintenance.package='#{new_resource.distribList}' -W product.location='#{new_resource.productHome}' -W update.type='install' -silent"
	raise "Invalid charachters found in install_command. Valid charachters are a-z, A-Z, 0-9, '-', '\\' and whitespace" unless install_command =~ /[0-9|a-z|A-Z|\s|\\|\-]*/

	doit = Mixlib::ShellOut.new(install_command, :user => new_resource.productUser, :group => new_resource.productGroup, :cwd => new_resource.updiHome)
	puts " " + doit.stdout
	doit.live_stdout = $stdout
	doit.run_command
	puts doit.stderr
	doit.error!
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
