include_recipe 'osl-docker'

directory '/var/lib/compose'

cookbook_file '/var/lib/compose/docker-compose.yml' do
  notifies :rebuild, 'osl_dockercompose[test]'
  notifies :restart, 'osl_dockercompose[test]'
end

cookbook_file '/var/lib/compose/docker-service1.yml' do
  notifies :rebuild, 'osl_dockercompose[services]'
  notifies :restart, 'osl_dockercompose[services]'
end

cookbook_file '/var/lib/compose/docker-service2.yml' do
  notifies :rebuild, 'osl_dockercompose[services]'
  notifies :restart, 'osl_dockercompose[services]'
end

osl_dockercompose 'test' do
  directory '/var/lib/compose'
end

osl_dockercompose 'services' do
  directory '/var/lib/compose'
  config_files %w(docker-service1.yml docker-service2.yml)
end
