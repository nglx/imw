module IMW
  class Metadata
    module Schematized

      # Return a fully summary of this Resource.
      #
      # The summary will include "external" information about how this
      # resource appears to the world (via its URI), "internal"
      # metadata about this resource (its description, &c.), as well
      # as the structure of this resource's data (it's schema's fields
      # and a snippet).
      #
      # Will return a Hash, with a <tt>:schema</tt> key which maps to
      # a well-formed AVRO schema for this resource.
      #
      # @return [Hash]
      def summary
        return @summary if @summary
        @summary            = external_summary
        p external_summary
        @summary[:schema]   = schema
        @summary[:contents] = resources.map(&:summary) if respond_to?(:resources)
        @summary
      end

      # Return informaiton (usually scheme-dependent) on how this
      # resource is situated in the world, i.e. - its URI, its size,
      # how many lines it has, &c.
      #
      # Modules which override this should chain with +super+:
      #
      #   # in my_scheme.rb
      #   def external_summary
      #     super().merge(:user => 'bob', :password => 'smith')
      #   end
      #
      # @return [Hash]
      def external_summary
        {
          :uri       => uri.to_s,
          :basename  => basename,
          :extension => extension
        }
      end

      # The schema for this object.
      #
      # @return [Hash]
      def schema
        return @schema if @schema
        @schema = {
          :type      => "record",
          :namespace => "schema.imw.resource",
          :name      => (basename || ''),
          :doc       => description,
          :fields    => fields,
          :non_avro  => {}
        }
        
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
          puts "I am examining #{d.path} for metadata information"
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
