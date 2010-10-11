module IMW
  module Parsers

    class Flat

      attr_accessor :io
      attr_accessor :state
      attr_accessor :accumulated
      attr_accessor :current

      def initialize io
        self.io          = io
        self.state       = nil
        self.accumulated = []
        self.current     = nil
      end

      def read_next!
        self.current = io.readline.chomp
      end

      def parse!
        while (! complete?)
          read_next!
          react_to_input!
        end
      end

      def accumulate!
        self.accumulated << current
      end

      def complete?
        io.eof?
      end

      def react_to_input!
        raise IMW::NotImplementedError.new("Override the `react_to_input!' method of the #{self.class} class")
      end
      
    end
  end
end

