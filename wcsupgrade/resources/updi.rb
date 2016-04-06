attribute :repository,		:kind_of => String,     :default => nil
attribute :distribPattern,	:kind_of => String,     :default => nil
attribute :updiHome,		:kind_of => String,     :default => nil
attribute :productHome,		:kind_of => String,     :default => nil
attribute :productUser,		:kind_of => String,     :default => nil
attribute :productGroup,	:kind_of => String,     :default => nil
attribute :distribList,		:kind_of => Array,      :default => nil
attribute :logFile,		:kind_of => String,     :default => "/tmp/iim.log"

distrTmp = "updi_src_tmp"


actions :prepare
actions :clean
actions :install
actions :update_product
actions :version
default_action :install


action :prepare do
	raise "repository was not provided" if new_resource.repository.nil?
	raise "updi distribPattern was not provided" if new_resource.distribPattern.nil?
        raise "product owner user was not provided" if new_resource.productUser.nil?
        raise "product owner group was not provided" if new_resource.productGroup.nil?
        raise "tmp folder #{new_resource.repository}/#{distrTmp} already exists" if Dir.exists?("#{new_resource.repository}/#{distrTmp}")

	execute 'unzip' do
		command	"unzip -q #{new_resource.repository}/#{new_resource.distribPattern} -d #{new_resource.repository}/#{distrTmp}"
		cwd	new_resource.repository
	end

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


action :update_product do
        raise "updi home directory was not provided" if new_resource.updiHome.nil?
        raise "product home directory was not provided" if new_resource.productHome.nil?
        raise "product owner user was not provided" if new_resource.productUser.nil?
        raise "product owner group was not provided" if new_resource.productGroup.nil?
        raise "distrib lists was not provided" if new_resource.distribList.nil?

	distribs = ""
	distribList.each do |distrib|
		distribs << "#{distrib};"
		raise "#{distrib} not exists" unless ::File.exists?(distrib)
	end

	execute 'check_if_product_running' do
		command	"ps aux | grep #{new_resource.productHome} | grep -v 'grep'"
		returns	1
	end

	install_command = "echo #{new_resource.updiHome}/update.sh -OPT checkFilePermissions='true' -W maintenance.package='#{distribs}' -W product.location='#{new_resource.productHome}' -W update.type='install' -silent"
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

	install_command = "#{new_resource.productHome}/bin/versionInfo.sh |egrep 'Name|Version  '"

	doit = Mixlib::ShellOut.new(install_command, :user => new_resource.productUser, :cwd => new_resource.productHome)
	puts " " + doit.stdout
	doit.live_stdout = $stdout
	doit.run_command
	puts doit.stderr
	doit.error!
end
