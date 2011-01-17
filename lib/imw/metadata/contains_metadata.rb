 module IMW
  class Metadata

    # A module for finding metadata describing the sub-resources of a
    # given resource.
    #
    # An including class describing the parent resource must define
    # the +contents+ method which must return an Array of Strings
    # contained within the parent .  These objects will be matched
    # against possible metadata URIs and the corresponding
    # IMW::Metadata class created on the fly.
    #
    # In case no such object is found, the class should also define
    # the +basename+ and +path+ methods which will be used to generate
    # a default URI where metadata about the parent's resources should
    # live.
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
        contents.detect { |path| path =~ /(icss|metadata).*\.(ya?ml|json)$/i } || File.join(path, "#{basename}.icss.yaml")
      end

      # Return the metadata for this resource if it exists.
      #
      # Will look for an existing resource at +default_metadata_uri+.
      #
      # @return [IMW::Metadata, nil]
      def metadata
        return @metadata if @metadata
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
