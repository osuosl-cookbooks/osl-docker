include_recipe 'osl-docker'

directory '/var/lib/compose'

cookbook_file '/var/lib/compose/docker-compose.yml' do
  notifies :rebuild, 'osl_dockercompose[test]'
  notifies :restart, 'osl_dockercompose[test]'
end

osl_dockercompose 'test' do
  directory '/var/lib/compose'
end
