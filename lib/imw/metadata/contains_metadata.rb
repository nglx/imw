module IMW
  class Metadata

    # A module that can be mixed into any class defining a +contents+
    # methods which returns an Array of URI strings.
    module ContainsMetadata
      
      # The path at which this resource's metadata file lives.
      #
      # Will default to any file beginning with +metadata+ and ending
      # with a +yaml+ or +json+ extension contained in this resource's
      # +contents+.
      #
      # @return [String, nil]
      def metadata_uri
        @metadata_uri ||= contents.detect { |path| path =~ /metadata.*\.(ya?ml|json)$/ }
      end

      # Explicitly set the path to the metadata for this resource.
      attr_writer :metadata_uri
      
      # Does this resource contain metadata for other resources it
      # contains?
      #
      # @return [true, false]
      def metadata?
        (!! metadata_uri)
      end

      # Return the metadata for this resource.
      #
      # @return [IMW::Metadata, nil]
      def metadata
        @metadata ||= metadata? && IMW::Metadata.load(metadata_uri)
      end

      # Explicitly set the metadata for this resource.
      attr_writer :metadata
      
    end
  end
end


