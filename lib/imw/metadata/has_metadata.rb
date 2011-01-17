module IMW
  class Metadata


    # A module which defines how a resource finds Metadata that it can
    # look up metadata about itself.
    #
    # "metadata" in this context is defined as accessors for
    # +metadata+ (IMW::Metadata), +schema+ (IMW::Metadata::Schema),
    # +fields+ (IMW::Metadata::Field), and +description+ (String).
    #
    # An including class should define a method +dir+ which should
    # return an object that might contain Metadata, i.e. - that
    # includes the IMW::Metadata::ContainsMetadata module.
    #
    # An including class can optionally define the methods +snippet+
    # which returns a snippet of the resource as well as
    # +record_count+ to return a count of how many records the
    # resource contains.
    module HasMetadata

      # The schema for this object.
      #
      # @return [Hash]
      def schema
        return @schema if @schema
        @schema             = IMW::Metadata::Schema.new
        @schema[:type]      = "record"
        @schema[:namespace] = "schema.imw.resource"
        @schema[:name]      = (basename || '')
        @schema[:doc]       = description
        @schema[:fields]    = fields
        
        @schema[:non_avro ] = {}
        @schema[:non_avro][:snippet]      = snippet      if respond_to?(:snippet)
        @schema[:non_avro][:record_count] = record_count if respond_to?(:record_count)
        @schema
      end

      # Return the metadata object that contains metadata for this
      # resource.
      #
      # Will look in this resource's directory and recursively upward
      # till the root directory is reached or a metadata file is
      # discovered.
      #
      # @return [IMW::Metadata, nil]
      def metadata
        return @metadata if @metadata
        d = dir
        while d.path != '/'
          break if d.metadata && d.metadata.describes?(self)
          d = d.dir
        end
        @metadata = d.metadata
      end

      # The fields for this resource's data.
      #
      # Each field will be a Hash of information.
      #
      # @return [Array<Hash>]
      def fields
        @fields ||= metadata && metadata.fields_for(self)
      end

      # Set the fields for this resource.
      #
      # @param [Array<Hash>] new_fields
      # @return [Array<Hash>]
      def fields= new_fields
        @fields = new_fields.map { |f| Metadata::Field.new(f) }
      end

      # A description for this Resource.
      #
      # @return [String]
      def description
        @description ||= metadata && metadata.description_for(self)
      end

      # Set the description of this Resource.
      #
      # @param [String] new_description
      # @return [String]
      def description= new_description
        @description = new_description
      end
      
    end
  end
end

