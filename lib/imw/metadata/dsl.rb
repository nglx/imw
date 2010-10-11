module IMW
  class Metadata

    # A module which defines a DSL that can be used to define metadata
    # for an object.
    module DSL
      
      # Open a new resource at the given URI.
      #
      # If this dataset has metadata and it describes the resource
      # then configure the resource to understand its schema..
      #
      # The +schema+ property passed via the options hash will
      # override this.
      # 
      # @param [String, Addressable::Uri, IMW::Resource] uri
      # @param [Hash] options
      # @return [IMW::Resource]
      # @see IMW.open
      def open uri, options={}, &block
        schema_options = (options[:schema].nil? && metadata && metadata.describe?(uri)) ? {:schema => metadata[uri]} : {}
        IMW.open(uri, options.merge(schema_options), &block)
      end

      def open! uri, options={}, &block
        self.open(uri, options.merge(:mode => 'w'), &block)
      end

      # When called without a block return this object's metadata.
      # 
      #   metadata
      #   #=> { '/path/to/file' => [...], '/path/to/other/file' => [...], ... }
      #
      # When called with a block, accumulate schema and fields into
      # this object's metadata
      #
      #   metadata do
      #
      #     schema "/path/to/file" do
      #       # ...
      #     end
      #
      #     schema "/path/to/other/file" do
      #       # ...
      #     end
      #   end
      #
      # @see [IMW::Metadata::Schema]
      # @see [IMW::Metadata::Field]      
      # @return [IMW::Metadata]
      def metadata arg=nil, options={}, &block
        case arg
        when Hash 
          @metadata ||= Metadata.new(arg, options)
        when nil
          @metadata ||= Metadata.new nil, options
        else
          @metadata ||= Metadata.load(arg, options)
        end
        @metadata.base = options[:base] if options[:base]
        return @metadata unless block_given?
        yield
      end

      def schema resource, options={}, &block
        new_field_accumulator!
        yield
        metadata[resource] = Schema.new(last_field_accumulator!)
      end

      def field name, options={}
        accumulate_field Field.new(options.merge(:name => name))
      end

      def has_one name, options={}, &block
        new_field_accumulator!
        yield
        accumulate_field Field.new(options.merge(:name => name, :has_one => last_field_accumulator!))
      end

      def has_many name, options={}, &block
        new_field_accumulator!
        yield
        accumulate_field Field.new(options.merge(:name => name, :has_many => last_field_accumulator!))
      end

      protected

      def field_accumulators    # :nodoc:
        @field_accumulators ||= []
      end
      
      def new_field_accumulator!    # :nodoc:
        field_accumulators.push([])
      end

      def last_field_accumulator!    # :nodoc:
        field_accumulators.pop
      end
      
      def field_accumulator?    # :nodoc:
        ! field_accumulators.empty?
      end

      def accumulate_field f    # :nodoc:
        # raise IMW::SchemaError.new("No record or sub-record to accumulate fields in!") unless field_accumulator?
        field_accumulators.last << f if field_accumulator?
      end
    end
  end
end
