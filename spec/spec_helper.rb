require 'chefspec'
require 'chefspec/berkshelf'

CENTOS_7 = {
  platform: 'centos',
  version: '7',
  file_cache_path: '/var/chef/cache',
}.freeze

DEBIAN_9 = {
  platform: 'debian',
  version: '9',
  file_cache_path: '/var/chef/cache',
}.freeze

ALL_PLATFORMS = [
  CENTOS_7,
  DEBIAN_9,
].freeze

CENTOS_PLATFORMS = [
  CENTOS_7,
].freeze

DEBIAN_PLATFORMS = [
  DEBIAN_9,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end
