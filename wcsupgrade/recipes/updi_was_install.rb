#
# Cookbook Name:: wcsuprade
# Recipe:: updi_was_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

wcsupgrade_updi 'updi-was' do
        productHome	node['updi']['was']['home']
	productUser	node['updi']['was']['user']
	productGroup	node['updi']['was']['group']
        repository      node['repository']
	distribPattern	"#{node['updi']['was']['version']}-WS-UPDI-LinuxAMD64.zip"
        logFile         "/tmp/updi-was.install.log"
        action          [:prepare, :install, :version, :clean]
end
