require 'rubygems'
require 'imw/utils'

module IMW
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
    if block_given?
      yield resource
      resource.close
    else
      resource
    end
  end

end
