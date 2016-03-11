#
# Cookbook Name:: wcsuprade
# Recipe:: updi_wcs_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


remote_file "#{node['repository']}/download.updii.#{node['updi']['wcs']['version']}.linux.amd64.zip" do
        source  "ftp://public.dhe.ibm.com/software/websphere/commerce/70/updi#{node['updi']['wcs']['version']}/download.updii.#{node['updi']['wcs']['version']}.linux.amd64.zip"
        owner   node['updi']['wcs']['user']
        group   node['updi']['wcs']['group']
        mode    '0444'
        action  :create_if_missing
end

wcsupgrade_updi 'updi-wcs' do
	productHome	node['updi']['wcs']['home']
	productUser	node['updi']['wcs']['user']
	productGroup	node['updi']['wcs']['group']
        repository      node['repository']
	distribPattern	"download.updii.#{node['updi']['wcs']['version']}.linux.amd64.zip"
        logFile         "/tmp/updi-wcs.install.log"
        action          [:prepare, :install, :version, :clean]
end
