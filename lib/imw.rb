require 'imw/error'
require 'imw/uri'

module IMW

  autoload :Recordizer, 'imw/recordizer'

  class Resource

    attr_reader :uri

    def initialize(uri, mode='r')
      raise FileModeError.new("'#{mode}' is not a valid access mode") unless valid_modes.include? mode
      @uri = Uri.new(uri)
    end

    def close

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
