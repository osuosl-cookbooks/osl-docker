require 'chefspec'
require 'chefspec/berkshelf'

CENTOS_8 = {
  platform: 'centos',
  version: '8',
}.freeze

CENTOS_7 = {
  platform: 'centos',
  version: '7',
}.freeze

ALL_PLATFORMS = [
  CENTOS_8,
  CENTOS_7,
].freeze

DEBIAN_11 = {
  platform: 'debian',
  version: '11',
}.freeze

CENTOS_PLATFORMS = [
  CENTOS_8,
  CENTOS_7,
].freeze

DEBIAN_PLATFORMS = [
  DEBIAN_11,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
  config.file_cache_path = '/var/chef/cache'
end
