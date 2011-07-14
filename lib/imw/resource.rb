require 'imw/utils/has_uri'

module IMW
  class Resource

    attr_accessor :mode, :resource_options

    def initialize uri, options={}
      self.uri              = uri
      self.resource_options = options
      self.mode             = options[:mode] || 'r'
      extend_appropriately!(options)
    end

    # Provides resources with a wrapped Addressable::URI object.
    include IMW::Utils::HasURI

    # Gives IMW::Resource instances with the ability to dynamically
    # extend themselves with modules chosen from a set of handlers
    # stored by the IMW::Resource class.
    include IMW::Utils::DynamicallyExtendable
    [IMW::Schemes::HANDLERS, IMW::Formats::HANDLERS].each do |handlers|
      register_handlers *handlers
    end

    def should_exist!(message=nil)
      raise IMW::Error.new([message, "No path defined for #{self.inspect} extended by #{modules.join(' ')}"].compact.join(', '))          unless respond_to?(:path)
      raise IMW::Error.new([message, "No exist? method defined for #{self.inspect} extended by #{modules.join(' ')}"].compact.join(', ')) unless respond_to?(:exist?)
      raise IMW::PathError.new([message, "#{path} does not exist"].compact.join(', '))                                                    unless exist?
      self
    end

    def close
    end

    def reopen
      IMW.open(uri.to_s)
    end

  end
end
