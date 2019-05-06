require 'spec_helper'

describe 'docker' do
  it_behaves_like 'docker'
end

describe file('/etc/docker/daemon.json') do
  its(:content) { should match(/{\n}/) }
end

describe cron do
  it { should have_entry('15 * * * * /usr/bin/docker system prune --volumes -f  > /dev/null') }
  it { should have_entry('45 2 * * 0 /usr/bin/docker system prune -a -f  > /dev/null') }
end
