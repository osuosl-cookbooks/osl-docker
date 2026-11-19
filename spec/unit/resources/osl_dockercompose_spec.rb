require 'spec_helper'

describe 'osl_dockercompose' do
  platform 'almalinux'
  step_into :osl_dockercompose

  before do
    stubs_for_resource('execute[test up]') do |resource|
      # web is up, but db has no container at all, so the project is not running
      # and the execute has to run.
      allow(resource).to receive_shell_out(
        'docker compose -p test  ps -a --format json',
        { cwd: '/var/lib/test' }
      ).and_return(
        double(exitstatus: 0, stdout: %({"Name":"test-web-1","Service":"web","State":"running"}\n))
      )

      allow(resource).to receive_shell_out(
        'docker compose -p test  config --format json',
        { cwd: '/var/lib/test' }
      ).and_return(double(exitstatus: 0, stdout: %({"services":{"web":{},"db":{}}})))
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
      command: 'docker compose -p test  up -d --wait',
      cwd: '/var/lib/test',
      live_stream: true
    )
  end

  it do
    is_expected.to run_execute('test-configs rebuild').with(
      command: 'docker compose -p test-configs -f docker-compose.yml -f docker-compose-common.yml up --pull always --build -d --wait',
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

  # pull_images is off by default, so callers' runs don't even show the pull-rebuild execute
  it { expect(chef_run.find_resource(:execute, 'test pull-rebuild')).to be_nil }
end

describe 'osl_dockercompose pull_images' do
  platform 'almalinux'
  step_into :osl_dockercompose

  compose = 'docker compose -p pulled '
  dir = { cwd: '/var/lib/pulled' }
  config = %({"services":{"web":{"image":"nginx:alpine"},"app":{"build":{"context":"."},"image":"pulled-app"}}})
  ps_json = %({"ID":"c1","Service":"web","State":"running"}\n{"ID":"c2","Service":"app","State":"running"}\n)

  recipe do
    osl_dockercompose 'pulled' do
      directory '/var/lib/pulled'
      pull_images true
    end
  end

  def stub_running(resource, ps_json, config)
    allow(resource).to receive_shell_out('docker compose -p pulled  ps -a --format json', { cwd: '/var/lib/pulled' })
      .and_return(double(exitstatus: 0, stdout: ps_json))
    allow(resource).to receive_shell_out('docker compose -p pulled  config --format json', { cwd: '/var/lib/pulled' })
      .and_return(double(exitstatus: 0, stdout: config))
  end

  def stub_stale_check(resource, compose, dir, config, ps_json, running_id, wanted_id,
                       pull_stderr = " Image nginx:alpine Pulling \n Image nginx:alpine Pulled \n")
    allow(resource).to receive_shell_out("#{compose} pull --quiet --ignore-buildable --ignore-pull-failures", dir)
      .and_return(double(exitstatus: 0, stderr: pull_stderr))
    allow(resource).to receive_shell_out("#{compose} config --format json", dir)
      .and_return(double(exitstatus: 0, stdout: config))
    allow(resource).to receive_shell_out("#{compose} ps --format json", dir)
      .and_return(double(exitstatus: 0, stdout: ps_json))
    allow(resource).to receive_shell_out("docker inspect -f '{{.Image}}' c1")
      .and_return(double(exitstatus: 0, stdout: "#{running_id}\n"))
    allow(resource).to receive_shell_out("docker image inspect -f '{{.Id}}' nginx:alpine")
      .and_return(double(exitstatus: 0, stdout: "#{wanted_id}\n"))
  end

  context 'when every running container is on its tag' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') do |r|
        stub_stale_check(r, compose, dir, config, ps_json, 'sha256:new', 'sha256:new')
      end
    end

    it { is_expected.to_not run_execute('pulled up') }
    it { is_expected.to_not run_execute('pulled pull-rebuild') }
  end

  context 'when a running container is behind its tag' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') do |r|
        stub_stale_check(r, compose, dir, config, ps_json, 'sha256:old', 'sha256:new')
      end
    end

    it do
      is_expected.to run_execute('pulled pull-rebuild').with(
        command: 'docker compose -p pulled  up --pull missing --build -d --wait',
        cwd: '/var/lib/pulled',
        live_stream: true
      )
    end
  end

  context 'when the pull fails' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') do |r|
        # --ignore-pull-failures still exits 0; the failure is only an Error line on stderr
        stub_stale_check(r, compose, dir, config, ps_json, 'sha256:old', 'sha256:new',
                         " Image nginx:alpine Pulling \n Image nginx:alpine Error Get \"https://registry-1.docker.io/v2/\": EOF \n")
      end
    end

    # It warns and still recreates what the earlier pulls left behind
    it do
      expect(Chef::Log).to receive(:warn).with(/osl_dockercompose\[pulled\]: pulling images failed/).at_least(:once)
      is_expected.to run_execute('pulled pull-rebuild')
    end
  end
end
