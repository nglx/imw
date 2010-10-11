module IMW

  # A collection of classes for describing the metadata associated
  # with a dataset's fields.
  class Metadata < Hash
    
    autoload :Field,       'imw/metadata/field'
    autoload :Schema,      'imw/metadata/schema'
    autoload :Schematized, 'imw/metadata/schematized'
    autoload :DSL,         'imw/metadata/dsl'
    autoload :ContainsMetadata, 'imw/metadata/contains_metadata'

    # The resource this Schema is anchored to.
    #
    # This attribute is useful for letting relative paths in a
    # schema file refer to a common base URL.
    #
    # @return [IMW::Resource]
    attr_reader :base
    
    # Set the resource this Schema is anchored to.
    #
    # @param [IMW::Resource, String, Addressable::URI] new_base
    def base= new_base
      base_resource = IMW.open(new_base)
      base_resource.should_exist!("Metdata base directory must exist")
      raise IMW::PathError.new("Metadata base must be a directory") unless base_resource.is_directory?
      @base = base_resource
    end

    def initialize obj=nil, options={}
      super()
      self.base = options[:base] if options[:base]
      obj.each_pair { |resource, schema| self[resource] = Schema.new(schema) } if obj
    end

    def self.load metadata_resource, options
      resource = IMW.open(metadata_resource)
      new(resource.load, {:base => resource.dirname}.merge(options))
    end

    def []= resource_spec, schema_spec
      schema = schema_spec.is_a?(Schema) ? schema_spec : Schema.new(schema_spec)
      super(absolute_uri(resource_spec), schema_spec)
    end

    def [] resource_spec
      super(absolute_uri(resource_spec))
    end

    def describe? resource_spec
      has_key?(absolute_uri(resource_spec))
    end

    protected

    def absolute_uri resource_spec
      if base && resource_spec.to_s !~ %r{(^/|://)} # relative path
        base.join(resource_spec).to_s
      else
        resource_spec.to_s
      end
    end
    
  end
end
