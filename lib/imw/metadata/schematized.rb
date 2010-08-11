module IMW
  module Metadata
    module Schematized

      # The schema for this object.
      #
      # @return [IMW::Metadata::Schema, nil]
      def schema
        @schema
      end

      # Set a new schema for this object.
      #
      # Will call the object's +validate_schema!+ hook which should
      # check the schema and take the appropriate action if it's
      # invalid.
      #
      # @param [Array, IMW::Metadata::Schema] new_schema
      # @return [IMW::Metadata::Schema]
      def schema= new_schema
        @schema = IMW::Metadata::Schema.new(new_schema)
        validate_schema! if respond_to?(:validate_schema!)
        @schema
      end
    end  
  end
end
