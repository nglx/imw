require 'imw/resources/formats'
require 'imw/resources/schemes'
require 'imw/resources/archives_and_compressed'

module IMW

  # IMW::Resources is a namespace in which all the modules which
  # define different kinds of behavior for IMW::Resource objects are
  # defined.
  #
  # When an IMW::Resource is instantiated it eventually calls
  # IMW::Resources#extend_resource! which will iterate through the
  # handlers in IMW::Resources#handlers, extending the resource with
  # modules whose handler conditions are satisfied.
  #
  # A handler is just an Array with two elements.  The first should be
  # a module or a string identifying a module.  
  #
  # If the second element is a Regexp, the corresponding module will
  # be used if the regexp matches the resource's URI (as a string)
  #
  # If the second element is a Proc, it will be called with the
  # resource as its only argument and if it returns true then the
  # module will be used.
  #
  # You can define your own handlers by appending them to
  # IMW::Resources::USER_DEFINED_HANDLERS in your <tt>.imwrc</tt>
  # file.
  module Resources

    autoload :LocalObj,        'imw/resources/local'
    autoload :RemoteObj,       'imw/resources/remote'
    autoload :StringObj,       'imw/resources/string'
    autoload :Transferable,    'imw/resources/transferable'

    # Iterate through IMW::Resources#handlers and extend the given
    # +resource+ with modules whose handler conditions match the
    # resource.
    #
    # @param [IMW::Resource] resource the resource to extend
    # @return [IMW::Resource] the extended resource
    def self.extend_resource! resource
      handlers.each do |mod_name, handler|
        case handler
        when Regexp    then extend_resource_with_mod_or_string!(resource, mod_name) if handler =~ resource.uri.to_s
        when Proc      then extend_resource_with_mod_or_string!(resource, mod_name) if handler.call(resource)
        when TrueClass then extend_resource_with_mod_or_string!(resource, mod_name)
        else
          raise IMW::TypeError("A handler must be Regexp, Proc, or true")
        end
      end
      resource
    end

    # Basic handlers to determine whether the resource is local,
    # remote, or a string.
    BASIC_HANDLERS = [
                      ["LocalObj",  Proc.new { |resource| resource.scheme == 'file' || resource.scheme.blank?   } ],
                      ["RemoteObj", Proc.new { |resource| resource.scheme != 'file' && resource.scheme.present? } ],
                      ["StringObj", Proc.new { |resource| resource.is_stringio?                                 } ]
                     ]

    # Define this constant in your configuration file to add your own
    # handlers.
    USER_DEFINED_HANDLERS = [] unless defined?(USER_DEFINED_HANDLERS)

    # include handlers from other modules
    include IMW::Resources::Formats
    include IMW::Resources::Schemes
    
    # A list of handlers to try.  Define your own handlers in
    # IMW::Resources::USER_DEFINED_HANDLERS.
    #
    # @return [Array]
    def self.handlers
      # order here is important
      BASIC_HANDLERS + SCHEME_HANDLERS + ARCHIVE_AND_COMPRESSED_HANDLERS + FORMAT_HANDLERS + USER_DEFINED_HANDLERS
    end

    protected

    # Extend +resource+ with +mod_or_string+.  Will work hard to try
    # and interpret +mod_or_string+ as a module if it's a string.
    #
    # @param [IMW::Resource] resource the resource to extend
    #
    # @param [Module, String] mod_or_string the module or string
    # representing a module to extend the resource with
    def self.extend_resource_with_mod_or_string! resource, mod_or_string
      if mod_or_string.is_a?(Module)
        resource.extend(mod_or_string)
      else
        # Given a string "Mod::SubMod::SubSubMod" first split it into
        # its parts ["Mod", "SubMod", "SubSubMod"] and then begin
        # class_eval'ing them in order so that each is class_eval'd in
        # the scope of the one before it.
        #
        # There is almost certainly a better way to do this.
        mod_names = mod_or_string.to_s.split('::')
        mods = []
        mod_names.each_with_index do |name, index|
          if index == 0
            mods << class_eval(name)
          else
            begin
              mods << class_eval(name)
            rescue NameError
              mods << mods[index - 1].class_eval(name)
            end
          end
        end
        resource.extend(mods.last)
      end
    end
  end
end


