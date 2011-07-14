module IMW
  module Utils

    module DynamicallyExtendable

      def self.included obj
        obj.extend(ClassMethods)
      end

      def modules
        @modules ||= []
      end

      def extend mod
        modules << mod
        super mod
      end

      def extend_appropriately! options={}
        self.class.extend_instance! self, options
      end

      module ClassMethods

        def handlers
          @handlers ||= []
        end

        def register_handler mod, handler
          raise IMW::ArgumentError.new("Module must be either a Module or String")       unless mod.is_a?(Module)     || mod.is_a?(String)
          raise IMW::ArgumentError.new("Handler must be either a Regexp, Proc, or true") unless handler.is_a?(Regexp) || handler.is_a?(Proc) || handler == true
          handlers << [mod, handler]
        end

        def register_handlers *pairs
          pairs.each { |pair| register_handler *pair }
        end

        def extend_instance! instance, options={}
          return if options[:no_modules]
          options.reverse_merge!(:use_modules => [], :skip_modules => [])
          handlers.each do |mod_name, handler|
            case handler
            when Regexp    then extend_instance_with_mod_or_string!(instance, mod_name, options[:skip_modules]) if handler =~ instance.to_s
            when Proc      then extend_instance_with_mod_or_string!(instance, mod_name, options[:skip_modules]) if handler.call(instance)
            when TrueClass then extend_instance_with_mod_or_string!(instance, mod_name, options[:skip_modules])
            else           raise IMW::TypeError("A handler must be Regexp, Proc, or true")
            end
          end
          options[:use_modules].each { |mod_name| extend_instance_with_mod_or_string!(instance, mod_name, options[:skip_modules]) }
          instance
        end

        def extend_instance_with_mod_or_string! instance, mod_or_string, skip_modules
          return if skip_modules.include?(mod_or_string)
          if mod_or_string.is_a?(Module)
            instance.extend(mod_or_string)
          else
            m = IMW.class_eval(mod_or_string)
            instance.extend(m) unless skip_modules.include?(m)
          end
        end
      end
    end
  end
end
