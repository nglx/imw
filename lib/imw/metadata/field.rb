module IMW

  class Metadata
    
    # Conceptually, a field is a "slot" for which "records" can have
    # values.
    #
    # An IMW::Metadata::Field is essentially a Hash that has one required
    # property: a name.
    #
    #   IMW::Metadata::Field.new('id')
    #   #=> { 'name' => 'id' }
    #
    # But you can declare as many other properties as you want (as long
    # as you include a +name+):
    #
    #   IMW::Metadata::Field.new 'name' => 'id', 'type' => :integer, 'title' => "ID", 'description' => "Auto-incremented."
    #   #=> { 'name' => 'id', 'type' => :integer, 'title' > "ID", 'description' => "Auto-incremented." }
    #
    # Some properties make a field special:
    #
    # <tt>has_many</tt>::
    #   Denotes that this record is in a "has_many" relationship with
    #   one or more other records.  The corresponding value should be
    #   an array
    #   
    # <tt>has_one</tt>::
    #   Denotes that this record is in a "has_one" relationship with
    #   one or more other records.  The corresponding value should be
    #   an Array in which each key names the joined record and each
    #   value is an Array of fields describing the joined record..
    #
    # @see IMW::Metadata::Record for more usage of the
    # <tt>:has_many</tt> and <tt>:has_one</tt> properties.
    class Field < Hash

      def initialize obj
        super()
        if obj.is_a?(Hash) || obj.is_a?(Field)
          merge!(obj)
          raise IMW::ArgumentError.new("A field must have a name") if obj['name'].blank?
        else
          self['name'] = obj.to_s.strip
        end
      end
      
      def hierarchical?
        has_key?('has_many') || has_key?('has_one')
      end
      alias_method :nested?, :hierarchical?

      def flat?
        ! hierarchical?
      end

      def titleize
        self['title'] || self['name'].capitalize # FIXME we can do better than this!
      end

      def associations
      end
      
    end
  end
end
