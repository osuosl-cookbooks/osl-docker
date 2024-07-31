require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
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
  DEBIAN_12,
  UBUNTU_2404,
].freeze

RHEL_PLATFORMS = [
  ALMA_8,
].freeze

DEBIAN_PLATFORMS = [
  DEBIAN_12,
  UBUNTU_2404,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
  config.file_cache_path = '/var/chef/cache'
end
