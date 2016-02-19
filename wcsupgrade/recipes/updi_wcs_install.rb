#
# Cookbook Name:: wcsuprade
# Recipe:: updi_wcs_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

wcsupgrade_updiwcs 'updi-wcs' do
        updiHome	node['updi']['wcs']['home']
	updiVersion	node['updi']['wcs']['version']
        repository      node['repository']
        logFile         "/tmp/updi-wcs.install.log"
        action          [:install, :version]
end
