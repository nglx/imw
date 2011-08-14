module IMW
  module Recordizer
    module PatternMunger
      def self.included(base)
        base.class_eval do
          base.extend ClassMethods
          class_attribute :consumers ; self.consumers = []
          class_attribute :max_lines ; self.max_lines = 100
        end
      end

      attr_accessor :_lines, :_rest
      def initialize(*args, &block)
        super(*args,&block)
        self._lines ||= []
        self._rest  ||= []
      end

      def munge_rest(match)
        _rest << match.string.to_s[0..5].strip
        true
      end

      def inspect
        ivars = {}.tap{|h| self.instance_variables.each{|ivar| h[ivar] = self.instance_variable_get(ivar).inspect[0..30] } }
        ivars.delete(:@_lines)
        line_1_snip = _lines.first.to_s.strip[0..20].strip
        line_n_snip = _lines.length > 1 ? "...'#{_lines.last.to_s.strip[0..20].strip}'" : ""
        %Q{#{self.class} #{ivars.inspect} _lines='#{line_1_snip}'#{line_n_snip}>}
      end

      def munge(buf)
        @consumers = self.class.consumers.map(&:dup)
        max_lines.times do
          self._lines << (line = buf.shift)
          break if buf.empty?
          res = run_consumers(line, buf)
          if res == :stop then buf.unshift(line) ; break ; end
          next  if res == :skip
          yield(line) if block_given?
        end
        self
      end

      def run_consumers(line, buf)
        @consumers.each do |det|
          res = det.munge(line, buf, self) do |mt|
            # self.send("munge_#{det.name}", mt) if respond_to?("munge_#{det.name}")
          end
          return(res) unless (res == :continue)
        end
        line
      end

      module ClassMethods
        def consumes(name, regexp, options={}, &block)
          if options[:into]
            into_attr_name = options[:into]
            block = lambda{|match, buf| self.send(into_attr_name) << match.string }
          end
          self.consumers += [Consumer.new(name, regexp, options, &block)]
        end
      end
    end

    class Consumer
      attr_accessor :name
      attr_accessor :regexp
      attr_accessor :options
      attr_accessor :limit
      attr_accessor :on_match

      def initialize(name, regexp, options={}, &block)
        self.name     = name
        self.regexp   = regexp
        self.limit    = options[:limit]
        self.on_match = options[:with] || block
        @num_seen = 0
      end

      def munge(line, buf, obj)
        mt = regexp.match(line) or return(:continue)
        return :skip if name == :skip
        return :stop if limit && @num_seen >= limit
        @num_seen += 1
        blk = on_match.is_a?(Symbol) ? obj.method(on_match) : on_match
        obj.instance_exec(mt, buf, &blk) if blk
        yield(mt)
      end
    end
  end
end
