require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'osl-docker' }

CENTOS_7 = {
  platform: 'centos',
  version: '7.2.1511'
}.freeze

DEBIAN_8 = {
  platform: 'debian',
  version: '8.4'
}.freeze

ALL_PLATFORMS = [
  CENTOS_7,
  DEBIAN_8
].freeze

RSpec.configure do |config|
  config.log_level = :fatal
end
