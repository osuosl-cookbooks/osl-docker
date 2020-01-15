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

DEBIAN_9 = {
  platform: 'debian',
  version: '9',
}.freeze

DEBIAN_10 = {
  platform: 'debian',
  version: '10',
}.freeze

ALL_PLATFORMS = [
  CENTOS_8,
  CENTOS_7,
  DEBIAN_9,
  DEBIAN_10,
].freeze

CENTOS_PLATFORMS = [
  CENTOS_8,
  CENTOS_7,
].freeze

DEBIAN_PLATFORMS = [
  DEBIAN_9,
  DEBIAN_10,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
  config.file_cache_path = '/var/chef/cache'
end
