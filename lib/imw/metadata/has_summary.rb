module IMW
  class Metadata

    # A module for generating a summary & schema of a resource.
    #
    # The including class should define methods +uri+, +basename+, +extension+.
    module HasSummary
      
      # Return a full summary of this Resource.
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
        @summary = {}
        begin
          @summary.merge!(external_summary)
          @summary[:schema]   = schema                   if respond_to?(:schema)
          @summary[:contents] = resources.map(&:summary) if respond_to?(:resources)
          @summary
        rescue => e
          # IMW.warn "Error in producing summary for #{self}: #{e.class} -- #{e.message}"
          return @summary
        end
      end

      # Return information (usually scheme-dependent) on how this
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
    end

  end
end
