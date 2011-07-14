module IMW
  module Recordizer
    class HTMLSelectorRecordizer

      def self.element(*args, &block)
        selector, name, delegate = parse_rule_declaration(*args, &block)
        rules[name] = [selector, delegate]
        attr_accessor name
        name
      end

      def self.elements(*args, &block)
        name = element(*args, &block)
        rules[name] << true
      end

      def initialize
        self.class.rules.each { |name, (s, k, plural)| send("#{name}=", []) if plural }
      end

      def self.recordize(doc)
        self.new.recordize(doc)
      end

      def recordize(doc)
        self.class.rules.each do |target, (selector, delegate, plural)|
          if plural
            send(target).concat doc.search(selector).map { |i| parse_result(i, delegate) }
          else
            send("#{target}=", parse_result(doc.at(selector), delegate))
          end
        end
        self.to_hash
      end

      def to_hash
        converter = lambda { |obj| obj.respond_to?(:to_hash) ? obj.to_hash : obj }
        self.class.rules.keys.inject({}) do |hash, name|
          value = send(name)
          hash[name.to_sym] = Array === value ? value.map(&converter) : converter[value]
          hash
        end
      end

      protected

      def parse_result(node, delegate)
        if delegate
          delegate.respond_to?(:call) ? delegate.call(node) : delegate.recordize(node)
        elsif node.respond_to? :inner_text
          node.inner_text
        else
          node
        end unless node.nil?
      end

      private

      def self.rules
        @rules ||= {}
      end

      def self.inherited(subclass)
        subclass.rules.update self.rules
      end

      # Rule declaration forms:
      #
      #   { 'selector' => :property, :with => delegate }
      #     #=> ['selector', :property, delegate]
      #
      #   :title
      #     #=> ['title', :title, nil]
      def self.parse_rule_declaration(*args, &block)
        options, name = Hash === args.last ? args.pop : {}, args.first
        delegate = options.delete(:with)
        selector, property = name ? [name.to_s, name.to_sym] : options.to_a.flatten
        raise ArgumentError, "invalid rule declaration: #{args.inspect}" unless property
        # eval block in context of a new scraper subclass
        delegate = Class.new(delegate || Nibbler, &block) if block_given?
        return selector, property, delegate
      end

    end
  end
end
