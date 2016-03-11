#
# Cookbook Name:: wcsuprade
# Recipe:: updi_was_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

remote_file "#{node['repository']}/#{node['updi']['was']['version']}-WS-UPDI-LinuxAMD64.zip" do
        source  "ftp://public.dhe.ibm.com/software/websphere/appserv/support/tools/UpdateInstaller/7.0.x/LinuxAMD64/#{node['updi']['was']['version']}-WS-UPDI-LinuxAMD64.zip"
        owner   node['updi']['was']['user']
        group   node['updi']['was']['group']
        mode    '0444'
        action  :create_if_missing
end

wcsupgrade_updi 'updi-was' do
        productHome	node['updi']['was']['home']
	productUser	node['updi']['was']['user']
	productGroup	node['updi']['was']['group']
        repository      node['repository']
	distribPattern	"#{node['updi']['was']['version']}-WS-UPDI-LinuxAMD64.zip"
        logFile         "/tmp/updi-was.install.log"
        action          [:prepare, :install, :version, :clean]
end
