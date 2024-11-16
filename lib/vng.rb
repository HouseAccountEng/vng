require 'date'
require 'digest/md5'
require 'json'
require 'net/http'
require 'uri'

require_relative 'vng/asset'
require_relative 'vng/availability'
require_relative 'vng/breed'
require_relative 'vng/case'
require_relative 'vng/config'
require_relative 'vng/contact'
require_relative 'vng/franchise'
require_relative 'vng/lead'
require_relative 'vng/location'
require_relative 'vng/lock'
require_relative 'vng/price_item'
require_relative 'vng/security_token'
require_relative 'vng/service_type'
require_relative 'vng/version'
require_relative 'vng/work_order'
require_relative 'vng/zip'

module Vng
  class Error < StandardError; end
  # Your code goes here...
end
