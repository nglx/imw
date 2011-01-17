module IMW

  class Metadata
    
    # Represents a schema for data.
    #
    # FIXME add methods that help couple nicely with Avro schemata.
    class Schema < Hash

      def initialize obj=nil
        super()
        merge!(obj) if obj.is_a?(Hash) || obj.is_a?(Schema)
      end

    end
  end
end
