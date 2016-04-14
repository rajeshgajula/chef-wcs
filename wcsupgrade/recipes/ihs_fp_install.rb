#
# Cookbook Name:: wcsupgrade
# Recipe:: ihs_fp_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#1. create ihs stop script from template
template '/usr/opt/app/IBM/scripts/ihs.sh' do
  source 'ihs.sh.erb'
  owner 'root'
  group 'root'
  mode '0750'
end

#2. download FP from ibm-ftp
verShort=node['ihs']['fp_version'].gsub(/\./,'')
verMajor=node['ihs']['fp_version'].gsub(/(\d+)\.(\d+)\..+/,'\1\2')
verPrefix=node['ihs']['fp_version'].gsub(/(.+)\.(.+)$/,'\1')
verSuffix=node['ihs']['fp_version'].gsub(/.+\.(.+)$/,'\1')
distrib_list = []

['32', '64'].each do |xBit|
  distribs = ["#{verPrefix}-WS-IHS-LinuxX#{xBit}-FP00000#{verSuffix}.pak", "#{verPrefix}-WS-PLG-LinuxX#{xBit}-FP00000#{verSuffix}.pak", "#{verPrefix}-WS-WASSDK-LinuxX#{xBit}-FP00000#{verSuffix}.pak"]
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

#3. check 15GB free space
wcsupgrade_utils 'opt-free-space before backup' do
	spaceLimitGB	15
        action		:check_free_space
end

#4. stop all ihs instances
wcsupgrade_utils 'stop-ihs' do
	productHome	'/usr/opt/app/IBM/scripts'
	execScript	'/usr/opt/app/IBM/scripts/ihs.sh stop'
	productUser	'root'
	productGroup	'root'
	action		:execit
end

#4.1. check if all stopped
wcsupgrade_utils 'check running' do
	productHome     node['ihs']['home']
	action          :check_if_running
end

#5. do backup
wcsupgrade_utils 'backup-ihs' do
	productHome	node['ihs']['home']
	productUser	node['ihs']['user']
	productGroup	node['ihs']['group']
	backupLocation	node['backup']['folder']
	backupName	"HTTPServer-before-#{node['ihs']['fp_version']}"
	action		:backup
end

#6. check 10GB free space
wcsupgrade_utils 'opt-free-space after backup' do
	spaceLimitGB    10
	action          :check_free_space
end

#7.1. update ihs if no instances and if distribs are in place
wcsupgrade_updi 'update ihs' do
	updiHome	node['updi']['was']['home']
	productHome	node['ihs']['home']
	productUser	'root'
	productGroup	'root'
	distribList	distrib_list
	action		:update_product
end

#7.2. update plg if no instances and if distribs are in place
wcsupgrade_updi 'update plg' do
	updiHome	node['updi']['was']['home']
	productHome	node['plg']['home']
	productUser	'root'
	productGroup	'root'
	distribList	distrib_list
	action		:update_product
end

#8. start instances
wcsupgrade_utils 'start-ihs' do
	productHome	'/usr/opt/app/IBM/scripts'
	execScript	'/usr/opt/app/IBM/scripts/ihs.sh start'
	productUser	'root'
	productGroup	'root'
	action		:execit
end

#9.1. show ihs version
wcsupgrade_updi 'ihs-version' do
	productHome	node['ihs']['home']
	productUser	node['ihs']['user']
	productGroup	node['ihs']['group']
	action		:version
end

#9.2. show plg version
wcsupgrade_updi 'plg-version' do
	productHome	node['plg']['home']
	productUser	node['plg']['user']
	productGroup	node['plg']['group']
	action		:version
end
