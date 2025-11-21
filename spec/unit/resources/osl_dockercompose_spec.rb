require 'spec_helper'

describe 'osl_dockercompose' do
  platform 'almalinux'
  step_into :osl_dockercompose

  before do
    stubs_for_resource('execute[test up]') do |resource|
      # Stub for docker compose ps -a --format json (returns empty, so not running)
      allow(resource).to receive_shell_out(
        'docker compose -p test  ps -a --format json',
        { cwd: '/var/lib/test' }
      ).and_return(double(exitstatus: 0, stdout: ''))
    end
  end

  recipe do
    osl_dockercompose 'test' do
      directory '/var/lib/test'
    end

    osl_dockercompose 'test-configs' do
      directory '/var/lib/test-configs'
      config_files %w(docker-compose.yml docker-compose-common.yml)
      action [:rebuild, :restart]
    end
  end

  it do
    is_expected.to run_execute('test up').with(
      command: 'docker compose -p test  up -d',
      cwd: '/var/lib/test',
      live_stream: true
    )
  end

  it do
    is_expected.to run_execute('test-configs rebuild').with(
      command: 'docker compose -p test-configs -f docker-compose.yml -f docker-compose-common.yml up --pull always --build -d',
      cwd: '/var/lib/test-configs',
      live_stream: true
    )
  end

  it do
    is_expected.to run_execute('test-configs restart').with(
      command: 'docker compose -p test-configs -f docker-compose.yml -f docker-compose-common.yml restart',
      cwd: '/var/lib/test-configs',
      live_stream: true
    )
  end
end
