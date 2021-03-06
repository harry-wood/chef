#
# Cookbook Name:: imagery
# Resource:: imagery_layer
#
# Copyright 2016, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :create

property :layer, String, :name_property => true
property :site, String, :required => true
property :source, String, :required => true
property :root_layer, [TrueClass, FalseClass], :default => false
property :text, String
property :copyright, String, :default => "Copyright"
property :projection, String, :default => "EPSG:3857"
property :palette, String
property :extent, String
property :background_colour, String
property :resample, String, :default => "average"
property :imagemode, String
property :extension, String,
         :is => %w(png png8 jpeg),
         :default => "png"
property :max_zoom, Fixnum, :default => 23
property :url_aliases, [String, Array], :default => []

action :create do
  template "/srv/imagery/mapserver/layer-#{layer}.map" do
    cookbook "imagery"
    source "mapserver.map.erb"
    owner "root"
    group "root"
    mode 0644
    variables new_resource.to_hash
  end

  template "/etc/init/mapserv-fcgi-layer-#{layer}.conf" do
    cookbook "imagery"
    source "mapserv_fcgi.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables new_resource.to_hash
  end

  service "mapserv-fcgi-layer-#{layer}" do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => false
    subscribes :restart, "template[/srv/imagery/mapserver/layer-#{layer}.map]"
    subscribes :restart, "template[/etc/init/mapserv-fcgi-layer-#{layer}.conf]"
  end

  directory "/srv/imagery/nginx/#{site}" do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end

  template "/srv/imagery/nginx/#{site}/layer-#{layer}.conf" do
    cookbook "imagery"
    source "nginx_imagery_layer_fragment.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables new_resource.to_hash
  end
end

action :delete do
  service "mapserv-fcgi-layer-#{layer}" do
    provider Chef::Provider::Service::Upstart
    action [:stop, :disable]
    supports :status => true, :restart => true, :reload => false
  end

  file "/srv/imagery/mapserver/layer-#{layer}.map" do
    action :delete
  end

  file "/etc/init/mapserv-fcgi-layer-#{layer}.conf" do
    action :delete
  end

  file "/srv/imagery/nginx/#{site}/layer-#{layer}.conf" do
    action :delete
  end
end

def after_created
  notifies :restart, "service[nginx]"
end
