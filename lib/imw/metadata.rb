module IMW

  # A collection of classes for describing the metadata associated
  # with a dataset's fields.
  class Metadata < Hash
    
    autoload :Field,            'imw/metadata/field'
    autoload :Schema,           'imw/metadata/schema'
    autoload :ContainsMetadata, 'imw/metadata/contains_metadata'
    autoload :HasSummary,       'imw/metadata/has_summary'
    autoload :HasMetadata,      'imw/metadata/has_metadata'

    # The resource this metadata is anchored to.
    #
    # This attribute is useful for letting relative paths in a
    # schema file refer to a common base URL.
    #
    # @return [IMW::Resource]
    attr_reader :base
    
    # Set the base resource this metdata is anchored to.
    #
    # @param [IMW::Resource, String, Addressable::URI] new_base
    def base= new_base
      base_resource = IMW.open(new_base)
      base_resource.should_exist!("Metadata base directory must exist")
      raise IMW::PathError.new("Metadata base must be a directory") unless base_resource.is_directory?
      @base = base_resource
    end

    def initialize obj=nil, options={}
      super()
      self.base = options[:base] if options[:base]
      if obj
        obj.each_pair do |resource, metadata|
          self[resource] = metadata
        end
      end
    end

    def self.load obj, options={}
      resource = IMW.open(obj)
      new(resource.load, {:base => resource.dirname}.merge(options))
    end

    def []= resource, metadata
      super(absolute_uri(resource), metadata)
    end

    def [] resource
      super(absolute_uri(resource))
    end

    def describe? resource
      self[(absolute_uri(resource))]
    end
    alias_method :describes?, :describe?

    def description_for resource
      return unless describes?(resource)
      self[resource]['description']
    end

    def fields_for resource
      return unless describes?(resource)
      (self[resource]['fields'] || []).map { |f| Metadata::Field.new(f) }
    end

    protected

    def absolute_uri resource
      obj = IMW.open(resource)
      if base && obj.uri.to_s !~ %r{(^/|://)} # relative path
        s = base.join(obj.uri.to_s).uri.to_s
        s
      else
        s = obj.uri.to_s
        s
      end
    end
    
  end
end
