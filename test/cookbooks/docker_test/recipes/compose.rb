include_recipe 'osl-docker'

directory '/var/lib/compose'

cookbook_file '/var/lib/compose/docker-compose.yml' do
  notifies :rebuild, 'osl_dockercompose[test]'
end

cookbook_file '/var/lib/compose/docker-service1.yml' do
  notifies :rebuild, 'osl_dockercompose[services]'
end

cookbook_file '/var/lib/compose/docker-service2.yml' do
  notifies :rebuild, 'osl_dockercompose[services]'
end

# No rebuild notification: the delayed rebuild would recreate the exited
# one-shot container after the prune below, breaking the prune simulation.
cookbook_file '/var/lib/compose/docker-oneshot.yml'

osl_dockercompose 'test' do
  directory '/var/lib/compose'
end

osl_dockercompose 'services' do
  directory '/var/lib/compose'
  config_files %w(docker-service1.yml docker-service2.yml)
end

osl_dockercompose 'oneshot' do
  directory '/var/lib/compose'
  config_files %w(docker-oneshot.yml)
end

# Simulate the docker_prune_containers cron reaping the exited one-shot
# container. With enforce_idempotency the second converge then proves
# osl_dockercompose[oneshot] still sees the project as running without it.
execute 'prune exited oneshot container' do
  command 'docker rm oneshot-migrate-1'
  only_if 'docker ps -a --filter name=^oneshot-migrate-1$ --filter status=exited --format "{{.Names}}" | grep -q .'
end
