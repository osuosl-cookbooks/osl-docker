require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'osl-docker' }

CENTOS_7 = {
  platform: 'centos',
  version: '7.4.1708',
  file_cache_path: '/var/chef/cache',
}.freeze

DEBIAN_8 = {
  platform: 'debian',
  version: '8.10',
  file_cache_path: '/var/chef/cache',
}.freeze

DEBIAN_9 = {
  platform: 'debian',
  version: '9.3',
  file_cache_path: '/var/chef/cache',
}.freeze

ALL_PLATFORMS = [
  CENTOS_7,
  DEBIAN_8,
  DEBIAN_9,
].freeze

CENTOS_PLATFORMS = [
  CENTOS_7,
].freeze

DEBIAN_PLATFORMS = [
  DEBIAN_8,
  DEBIAN_9,
].freeze

RSpec.configure do |config|
  config.log_level = :fatal
end
