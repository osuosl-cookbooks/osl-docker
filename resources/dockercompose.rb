resource_name :osl_dockercompose
provides :osl_dockercompose
unified_mode true

default_action :up

property :directory, String, required: true
property :config, Array, default: []

action :up do
  execute "#{new_resource.name} up" do
    command "docker compose -p #{new_resource.name} #{new_resource.config.map { |f| "-f #{f}" }.join(' ')} up -d"
    cwd new_resource.directory
    live_stream true
    not_if { osl_dockercompose_running? }
  end
end

action :rebuild do
  execute "#{new_resource.name} rebuild" do
    command "docker compose -p #{new_resource.name} #{new_resource.config.map { |f| "-f #{f}" }.join(' ')} up --pull always --build -d"
    cwd new_resource.directory
    live_stream true
  end
end

action :restart do
  execute "#{new_resource.name} restart" do
    command "docker compose -p #{new_resource.name} #{new_resource.config.map { |f| "-f #{f}" }.join(' ')} restart"
    cwd new_resource.directory
    live_stream true
  end
end
