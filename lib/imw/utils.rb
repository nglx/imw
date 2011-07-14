require 'rubygems'
require 'fileutils'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/string/starts_ends_with'
require 'imw/utils/error'
require 'imw/utils/log'
require 'imw/utils/paths'
require 'imw/utils/misc'

module IMW

  module Utils
    autoload :DynamicallyExtendable, 'imw/utils/dynamically_extendable'
    autoload :HasURI,                'imw/utils/has_uri'
  end

end

