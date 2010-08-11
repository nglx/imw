require 'rubygems'
require 'fileutils'
require 'imw/utils/error'
require 'imw/utils/log'
require 'imw/utils/paths'
require 'imw/utils/misc'
require 'imw/utils/extensions'

module IMW

  # Utility modules.
  module Utils
    autoload :DynamicallyExtendable, 'imw/utils/dynamically_extendable'
    autoload :HasURI,                'imw/utils/has_uri'
  end
end

