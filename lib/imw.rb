require 'rubygems'
require 'imw/utils'
require 'imw/error'
require 'imw/uri'

module IMW

  autoload :Recordizer,      'imw/recordizer'
  autoload :Resource,        'imw/resource'
  autoload :Schemes,         'imw/schemes'
  autoload :Formats,         'imw/formats'
  autoload :Parsers,         'imw/parsers'

  def self.open obj, options={}, &block
    if obj.is_a?(IMW::Resource)
      resource = obj
    else
      options[:use_modules]  ||= (options[:as]      || [])
      options[:skip_modules] ||= (options[:without] || [])
      resource = IMW::Resource.new(obj, options)
    end
  end

  class Resource

    attr_reader :uri

    def initialize(uri, mode='r')
      raise FileModeError.new("'#{mode}' is not a valid access mode") unless valid_modes.include? mode
      @uri = Uri.new(uri)
    end

    def self.open(uri, mode='r', &blk)
      resource = Resource.new(uri, mode)
      if block_given?
        yield resource
      else
        return resource
      end
    end

    def self.exists? resource
      true
    end

    private
    def valid_modes
      %w[ r w a ]
    end

  end

end
