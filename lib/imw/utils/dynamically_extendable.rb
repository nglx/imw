module IMW
  module Utils

    # Provides an including class with a class-level array of
    # "handlers" that it can use to dynamically extend its instances
    # with specific modules only if certain conditions are met.
    #
    # This allows different instances of a class to implement very
    # different behavior at runtime.
    #
    # An example use case might be a Database class which dynamically
    # extends its instances with an adaptor module appropriate to the
    # particular database the object refers to.
    module DynamicallyExtendable

      def self.included obj
        obj.extend(ClassMethods)
      end
      
      # Return the modules this object has been extended by.
      #
      # @return [Array]
      def modules
        @modules ||= []
      end

      # Works just like Object#extend except it keeps track of the
      # modules it has extended.
      #
      # @see IMW::Utils::DynamicallyExtendable#modules
      def extend mod
        modules << mod
        super mod
      end

      # Iterate through this object's class's handlers and extend this
      # object with the module referred to by any matching handlers.
      def extend_appropriately! options={}
        self.class.extend_instance! self, options
      end

      # A collection of methods which provide a class including
      # IMW::Utils::DynamicallyExtendable with a class-level Array of
      # handlers that can be applied to instances by calling the
      # instance's +extend_appropriately!+ method.
      module ClassMethods

        # The handlers an including class has defined.
        #
        # @return [Array<Array>]
        def handlers
          @handlers ||= []
        end
        
        # Register a new handler for an including class.
        #
        # +handler+ must be one of
        #
        # 1. Regexp 
        # 2. Proc 
        # 3. +true+
        #
        # In case (1), if the regular expression matches the
        # instance's +to_s+ method then the module (+mod+) will be
        # used..
        #
        # In case (2), if the Proc returns a value other than +false+
        # or +nil+ after being passed an instance then the module will
        # be used.
        #
        # In case (3), the module will be used.
        #
        # @param [String, Module] mod
        # @param [Regexp, Proc, true] handler
        def register_handler mod, handler
          raise IMW::ArgumentError.new("Module must be either a Module or String")       unless mod.is_a?(Module)     || mod.is_a?(String)
          raise IMW::ArgumentError.new("Handler must be either a Regexp, Proc, or true") unless handler.is_a?(Regexp) || handler.is_a?(Proc) || handler == true
          handlers << [mod, handler]
        end

        # Register a collection of handlers.
        #
        # @see IMW::Utils::DynamicallyExtendable::ClassMethods#register_handler
        def register_handlers *pairs
          pairs.each { |pair| register_handler *pair }
        end
        
        # Iterate through this class's handlers and extend the given
        # object with modules whose handler conditions match the
        # instance.
        #
        # Passing in <tt>:use_modules</tt> or <tt>:skip_modules</tt>
        # allows overriding the default behavior of handlers.
        #
        # @param [Object] instance
        # @param [Hash] options
        # @option options [Array<String,Module>] use_modules a list of modules used regardless of handlers
        # @option options [Array<String,Module>] skip_modules a list of modules not to be used regardless of handlers
        # @return [Object] the newly extended object
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
        
        # Extend +instance+ with +mod_or_string+.  Will work hard to
        # try and interpret +mod_or_string+ as a module if it's a
        # string.
        #
        # @param [Object] instance
        #
        # @param [Module, String] mod_or_string the module or string
        # representing a module to extend the instance with
        #
        # @param [Array<Module,String>] skip_modules modules to exclude
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
