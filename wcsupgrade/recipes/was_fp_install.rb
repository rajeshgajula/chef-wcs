#
# Cookbook Name:: wcsupgrade
# Recipe:: was_fp_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#1. create was stop script from template
template '/usr/opt/app/IBM/scripts/was.sh' do
  source	'was.sh.erb'
  owner		node['was']['user']
  group		node['was']['group']
  mode		'0750'
end

#2. download FP from ibm-ftp
verShort=node['was']['fp_version'].gsub(/\./,'')
verMajor=node['was']['fp_version'].gsub(/(\d+)\.(\d+)\..+/,'\1\2')
verPrefix=node['was']['fp_version'].gsub(/(.+)\.(.+)$/,'\1')
verSuffix=node['was']['fp_version'].gsub(/.+\.(.+)$/,'\1')
distrib_list = []

['32', '64'].each do |xBit|
  distribs = ["#{verPrefix}-WS-WAS-LinuxX#{xBit}-FP00000#{verSuffix}.pak", "#{verPrefix}-WS-WASSDK-LinuxX#{xBit}-FP00000#{verSuffix}.pak"]
  distribs.each do |distrib|
    distrib_list << "#{node['repository']}/#{distrib}"
    remote_file "#{node['repository']}/#{distrib}" do
        source  "ftp://public.dhe.ibm.com/software/websphere/appserv/support/fixpacks/was#{verMajor}/cumulative/cf#{verShort}/LinuxX#{xBit}/#{distrib}"
        owner   node['updi']['was']['user']
        group   node['updi']['was']['group']
        mode    '0444'
        action  :create_if_missing
    end
  end
end

#3. check 25GB free space
wcsupgrade_utils 'opt-free-space before backup' do
	spaceLimitGB	25
        action		:check_free_space
end

#4. stop all was instances
wcsupgrade_utils 'stop-was' do
	productHome	'/usr/opt/app/IBM/scripts'
	execScript	'/usr/opt/app/IBM/scripts/was.sh stop'
	productUser	node['was']['user']
	productGroup	node['was']['group']
	action		:execit
end

#5. do backup
wcsupgrade_utils 'backup-was' do
	productHome	node['was']['home']
	productUser	node['was']['user']
	productGroup	node['was']['group']
	backupLocation	node['backup']['folder']
	backupName	"AppServer-before-#{node['was']['fp_version']}"
	action		:backup
end

#6. check 15GB free space
wcsupgrade_utils 'opt-free-space after backup' do
        spaceLimitGB    15
        action          :check_free_space
end

#7. update was if no instances and if distribs are in place
wcsupgrade_updi 'update was' do
	updiHome	node['updi']['was']['home']
	productHome	node['was']['home']
	productUser	node['was']['user']
	productGroup	node['was']['group']
	distribList	distrib_list
	action		:update_product

end

#8. start instances
wcsupgrade_utils 'start-was' do
	productHome	'/usr/opt/app/IBM/scripts'
	execScript	'/usr/opt/app/IBM/scripts/was.sh start'
	productUser	node['was']['user']
	productGroup	node['was']['group']
	action		:execit
end

#9. show was version
wcsupgrade_updi 'was-version' do
	productHome	node['was']['home']
	productUser	node['was']['user']
	productGroup	node['was']['group']
	action		:version
end
