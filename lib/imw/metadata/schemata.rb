module IMW
  module Metadata

    # A collection of Schemas.
    class Schemata < Hash

      # The resource this Schemata is anchored to.
      #
      # This attribute is useful for letting relative paths in a
      # schemata file refer to a common base URL.
      #
      # @return [IMW::Resource]
      attr_reader :base
      
      # Set the resource this Schemata is anchored to.
      def base= new_base
        @base = IMW.open(new_base)
      end

      def initialize obj=nil
        super()
        obj.each_pair { |resource, schema| self[resource] = Schema.new(schema) } if obj
      end

      def self.load schemata_resource
        new(IMW.open(schemata_resource).load)
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
          base.dir.join(resource_spec).to_s
        else
          resource_spec.to_s
        end
      end
      
    end
  end
end
