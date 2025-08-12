require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
}.freeze

ALMA_9 = {
  platform: 'almalinux',
  version: '9',
}.freeze

ALMA_10 = {
  platform: 'almalinux',
  version: '10',
}.freeze

DEBIAN_12 = {
  platform: 'debian',
  version: '12',
}.freeze

UBUNTU_2404 = {
  platform: 'ubuntu',
  version: '24.04',
}.freeze

ALL_PLATFORMS = [
  ALMA_8,
  ALMA_9,
  ALMA_10,
  DEBIAN_12,
  UBUNTU_2404,
].freeze

ALL_RHEL = [
  ALMA_8,
  ALMA_9,
  ALMA_10,
].freeze

ALL_DEBIAN = [
  DEBIAN_12,
  UBUNTU_2404,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
  config.file_cache_path = '/var/chef/cache'
end

shared_context 'common_stubs' do
  before do
    stub_command('iptables -C INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null').and_return(true)
  end
end
