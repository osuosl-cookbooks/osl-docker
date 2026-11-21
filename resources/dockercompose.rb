resource_name :osl_dockercompose
provides :osl_dockercompose
unified_mode true

default_action :up

property :directory, String, required: true
property :config_files, Array, default: []
# Pull the stack's own images every converge and recreate whatever runs an outdated one
property :pull_images, [true, false], default: true

action :up do
  execute "#{new_resource.name} up" do
    command "docker compose -p #{new_resource.name} #{new_resource.config_files.map { |f| "-f #{f}" }.join(' ')} up -d --wait"
    cwd new_resource.directory
    live_stream true
    not_if { osl_dockercompose_running? }
  end

  # The guard has just pulled, so `up` must not pull again: it has no --ignore-pull-failures, and a
  # second pull of one flaky image would fail the run that pull_images is meant to let carry on.
  # No --wait: a recreated service that starts slowly, or an unrelated unhealthy one, must not fail
  # the converge; health is the healthcheck's and monitoring's job. No --build: :rebuild does that.
  if new_resource.pull_images
    execute "#{new_resource.name} pull-rebuild" do
      command "docker compose -p #{new_resource.name} #{new_resource.config_files.map { |f| "-f #{f}" }.join(' ')} up -d --pull never"
      cwd new_resource.directory
      live_stream true
      only_if { osl_dockercompose_stale? }
    end
  end
end

action :rebuild do
  execute "#{new_resource.name} rebuild" do
    command "docker compose -p #{new_resource.name} #{new_resource.config_files.map { |f| "-f #{f}" }.join(' ')} up --pull always --build -d --wait"
    cwd new_resource.directory
    live_stream true
  end
end

action :restart do
  execute "#{new_resource.name} restart" do
    command "docker compose -p #{new_resource.name} #{new_resource.config_files.map { |f| "-f #{f}" }.join(' ')} restart"
    cwd new_resource.directory
    live_stream true
  end
end
