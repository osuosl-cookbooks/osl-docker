require 'spec_helper'

describe service('docker') do
  it { should_not be_enabled }
  it { should_not be_running }
end

%w(docker dockerd).each do |cmd|
  describe command("#{cmd} --version") do
    if os[:family] == 'debian' && os[:release].to_i == 8
      its(:stdout) { should match(/18\.06\.3/) }
    else
      its(:stdout) { should match(/18\.09\.2/) }
    end
  end
end

describe command('docker ps') do
  its(:exit_status) { should eq 1 }
end

describe cron do
  it { should_not have_entry('15 * * * * /usr/bin/docker system prune --volumes -f  > /dev/null') }
  it { should_not have_entry('45 2 * * 0 /usr/bin/docker system prune -a -f  > /dev/null') }
end
