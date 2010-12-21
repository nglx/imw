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

      def titleize
        self['title'] || self['name'].capitalize # FIXME we can do better than this!
      end

    end
  end
end
