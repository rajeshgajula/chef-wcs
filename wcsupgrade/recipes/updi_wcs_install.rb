#
# Cookbook Name:: wcsuprade
# Recipe:: updi_wcs_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

wcsupgrade_updi 'updi-wcs' do
	productHome	node['updi']['wcs']['home']
	productUser	node['updi']['wcs']['user']
	productGroup	node['updi']['wcs']['group']
        repository      node['repository']
	distribPattern	"download.updii.#{node['updi']['wcs']['version']}.linux.amd64.zip"
        logFile         "/tmp/updi-wcs.install.log"
        action          [:prepare, :install, :version, :clean]
end
