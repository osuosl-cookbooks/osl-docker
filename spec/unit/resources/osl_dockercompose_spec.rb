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

    # pull_images is on by default: compose's dry run would recreate nothing
    stubs_for_resource('execute[test pull-rebuild]') do |resource|
      dir = { cwd: '/var/lib/test' }
      allow(resource).to receive_shell_out('docker compose -p test  pull --quiet --ignore-buildable --ignore-pull-failures', dir)
        .and_return(double(exitstatus: 0, stderr: ''))
      allow(resource).to receive_shell_out('docker compose -p test  --dry-run up -d --pull never --no-build', dir)
        .and_return(double(exitstatus: 0, stdout: '', stderr: " Container test-web-1 Running \n"))
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

  # pull_images is on by default, so :up carries the guarded pull-rebuild; web is current, so it is skipped
  it { expect(chef_run.find_resource(:execute, 'test pull-rebuild')).to_not be_nil }
  it { is_expected.to_not run_execute('test pull-rebuild') }

  # :rebuild and :restart never add it
  it { expect(chef_run.find_resource(:execute, 'test-configs pull-rebuild')).to be_nil }
end

describe 'osl_dockercompose pull_images false' do
  platform 'almalinux'
  step_into :osl_dockercompose

  recipe do
    osl_dockercompose 'held' do
      directory '/var/lib/held'
      pull_images false
    end
  end

  before do
    stubs_for_resource('execute[held up]') do |resource|
      allow(resource).to receive_shell_out('docker compose -p held  ps -a --format json', { cwd: '/var/lib/held' })
        .and_return(double(exitstatus: 0, stdout: %({"ID":"c1","Service":"web","State":"running"}\n)))
      allow(resource).to receive_shell_out('docker compose -p held  config --format json', { cwd: '/var/lib/held' })
        .and_return(double(exitstatus: 0, stdout: %({"services":{"web":{"image":"nginx:alpine"}}})))
    end
  end

  # Opting out leaves the stack as it was before pull_images existed
  it { expect(chef_run.find_resource(:execute, 'held pull-rebuild')).to be_nil }
end

describe 'osl_dockercompose pull_images by default' do
  platform 'almalinux'
  step_into :osl_dockercompose

  compose = 'docker compose -p pulled '
  dir = { cwd: '/var/lib/pulled' }
  config = %({"services":{"web":{"image":"nginx:alpine"},"app":{"build":{"context":"."},"image":"pulled-app"}}})
  ps_json = %({"ID":"c1","Service":"web","State":"running"}\n{"ID":"c2","Service":"app","State":"running"}\n)
  pulled = " Image nginx:alpine Pulling \n Image nginx:alpine Pulled \n"
  current = " Container pulled-web-1 Running \n Container pulled-app-1 Running \n"

  recipe do
    osl_dockercompose 'pulled' do
      directory '/var/lib/pulled'
    end
  end

  def stub_running(resource, ps_json, config)
    allow(resource).to receive_shell_out('docker compose -p pulled  ps -a --format json', { cwd: '/var/lib/pulled' })
      .and_return(double(exitstatus: 0, stdout: ps_json))
    allow(resource).to receive_shell_out('docker compose -p pulled  config --format json', { cwd: '/var/lib/pulled' })
      .and_return(double(exitstatus: 0, stdout: config))
  end

  def stub_stale_check(resource, compose, dir, pull_stderr, dry_stderr, dry_exit = 0)
    allow(resource).to receive_shell_out("#{compose} pull --quiet --ignore-buildable --ignore-pull-failures", dir)
      .and_return(double(exitstatus: 0, stderr: pull_stderr))
    allow(resource).to receive_shell_out("#{compose} --dry-run up -d --pull never --no-build", dir)
      .and_return(double(exitstatus: dry_exit, stdout: '', stderr: dry_stderr))
  end

  context 'when compose would recreate nothing' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') { |r| stub_stale_check(r, compose, dir, pulled, current) }
    end

    it { is_expected.to_not run_execute('pulled up') }
    it { is_expected.to_not run_execute('pulled pull-rebuild') }
  end

  context 'when compose would recreate a container' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') do |r|
        stub_stale_check(r, compose, dir, pulled, " Container pulled-web-1 Recreate \n Container pulled-web-1 Recreated \n")
      end
    end

    it do
      is_expected.to run_execute('pulled pull-rebuild').with(
        command: 'docker compose -p pulled  up -d --pull never',
        cwd: '/var/lib/pulled',
        live_stream: true
      )
    end
  end

  context 'when only an exited one-shot would start again' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') do |r|
        stub_stale_check(r, compose, dir, pulled, "#{current} Container pulled-migrate-1 Starting \n Container pulled-migrate-1 Started \n")
      end
    end

    it { is_expected.to_not run_execute('pulled pull-rebuild') }
  end

  context 'when the pull fails' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') do |r|
        # --ignore-pull-failures still exits 0; the failure is only an Error line on stderr
        stub_stale_check(r, compose, dir,
                         " Image nginx:alpine Pulling \n Image nginx:alpine Error Get \"https://registry-1.docker.io/v2/\": EOF \n",
                         " Container pulled-web-1 Recreate \n")
      end
    end

    # It warns and still recreates what the earlier pulls left behind
    it do
      expect(Chef::Log).to receive(:warn).with(/osl_dockercompose\[pulled\]: pulling images failed/).at_least(:once)
      is_expected.to run_execute('pulled pull-rebuild')
    end
  end

  context 'when the dry run fails' do
    before do
      stubs_for_resource('execute[pulled up]') { |r| stub_running(r, ps_json, config) }
      stubs_for_resource('execute[pulled pull-rebuild]') do |r|
        stub_stale_check(r, compose, dir, pulled, 'service "web" refers to undefined volume data', 1)
      end
    end

    it do
      expect(Chef::Log).to receive(:warn).with(/osl_dockercompose\[pulled\]: the dry run failed/).at_least(:once)
      is_expected.to_not run_execute('pulled pull-rebuild')
    end
  end
end
