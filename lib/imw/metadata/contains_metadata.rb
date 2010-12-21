 module IMW
  class Metadata

    # A module that can be mixed into any class defining a +contents+
    # methods which returns an Array of URI strings.
    module ContainsMetadata
      
      # The URI containing the metadata for this resource and its
      # contents.
      #
      # Looks for an existing JSON or YAML file containing the strings
      # "icss" or "metadata" directly contained within this resource.
      #
      # If none are found, defaults to a URI named after this
      # resource's basename with the string ".icss.yaml" appended.
      #
      # @return [String, nil]
      def default_metadata_uri
        contents.detect { |path| path =~ /(icss|metadata).*\.(ya?ml|json)$/i } || join("#{basename}.icss.yaml")
      end

      # Return the metadata for this resource if it exists.
      #
      # Will look for an existing resource at +default_metadata_uri+.
      #
      # @return [IMW::Metadata, nil]
      def metadata
        return @metadata if @metadata
        puts "I am about to examine #{self} for metadata.  The contents are #{contents.inspect}.  The default URI is #{default_metadata_uri}"
        obj = IMW.open(default_metadata_uri)
        self.metadata=(obj) if obj.exist?
        @metadata
      end

      # Set the metadata for this resource to +obj+.
      #
      # @param [String, Addressable::URI, IMW::Resource] obj
      def metadata= obj
        @metadata = IMW::Metadata.load(obj)
      end
      
    end
  end
end
