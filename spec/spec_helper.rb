require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
}.freeze

CENTOS_8 = {
  platform: 'centos',
  version: '8',
}.freeze

CENTOS_7 = {
  platform: 'centos',
  version: '7',
}.freeze

DEBIAN_11 = {
  platform: 'debian',
  version: '11',
}.freeze

ALL_PLATFORMS = [
  ALMA_8,
  CENTOS_8,
  CENTOS_7,
  DEBIAN_11,
].freeze

RHEL_PLATFORMS = [
  ALMA_8,
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
