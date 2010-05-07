require 'pathname'

module IMW

  # Implements methods designed to work with an object's
  # <tt>@paths</tt> attributes, adding and deleting symbolic
  # references to paths and expanding calls to +path_to+ from that
  # attribute or (when a miss) from <tt>IMW::PATHS</tt>.
  #
  # An including class should therefore define an array attribute
  # <tt>@paths</tt>.
  module Paths

    # Expands a shorthand workflow path specification to an actual
    # file path.  Strings are interpreted literally but symbols are
    # first resolved to the paths they represent.
    #
    #   add_path :foo, '~/whoa'
    #   path_to :foo, 'my_thing'
    #   => '~/whoa/my_thing'
    #
    # @param [String, Symbol] pathsegs the path segments to join
    # @return [String] the resulting expanded path
    def path_to *pathsegs
      path = Pathname.new path_to_helper(*pathsegs)
      path.absolute? ? File.expand_path(path) : path.to_s
    end

    # Return the presently defined paths for this object.
    #
    # @return [Hash]
    def paths
      @paths ||= {}
    end

    # Adds a symbolic path for expansion by +path_to+.
    # 
    #   add_path :foo, '~/whoa'
    #   add_path :bar, :foo,   'baz'
    #   path_to :bar
    #   => '~/whoa/baz'
    #
    # @param [Symbol] sym the name of the path to store
    # @param [Symbol, String] pathsegs the path segments to use to define the path to the name
    # @return [String] the resulting path
    def add_path sym, *pathsegs
      paths[sym] = pathsegs.flatten
      path_to(sym)
    end

    # Removes a symbolic path for expansion by +path_to+.
    #
    # @param [Symbol] sym the stored path symbol to remove
    def remove_path sym
      paths.delete sym if paths.include? sym
    end

    private
    def path_to_helper *pathsegs # :nodoc:
      # +path_to_helper+ handles the recursive calls for +path_to+.
      expanded = pathsegs.flatten.compact.map do |pathseg|
        case
        when pathseg.is_a?(Symbol) && paths.include?(pathseg)      then path_to(paths[pathseg])
        when pathseg.is_a?(Symbol) && IMW::PATHS.include?(pathseg) then path_to(IMW::PATHS[pathseg])          
        when pathseg.is_a?(Symbol)                                 then raise IMW::PathError.new("No path expansion set for #{pathseg.inspect}")
        else pathseg
        end
      end
      File.join(*expanded)
    end
  end


  # Default paths for the IMW.  Chosen to make sense on most *NIX
  # distributions.
  DEFAULT_PATHS = {
    :home         => ENV['HOME'],
    :data_root    => "/var/lib/imw",
    :log_root     => "/var/log/imw",
    :scripts_root => "/usr/share/imw",
    :tmp_root     => "/tmp/imw",

    # the imw library
    :imw_root  => File.expand_path(File.dirname(__FILE__) + "/../../.."),
    :imw_bin   => [:imw_root, 'bin'],
    :imw_etc   => [:imw_root, 'etc'],
    :imw_lib   => [:imw_root, 'lib'],

    # workflow
    :ripd_root  => [:data_root, 'ripd'],
    :rawd_root  => [:data_root, 'rawd'],
    :fixd_root  => [:data_root, 'fixd'],
    :pkgd_root  => [:data_root, 'pkgd']
  }
  defined?(PATHS) ? PATHS.reverse_merge!(DEFAULT_PATHS) : PATHS = DEFAULT_PATHS

  # Expands a shorthand workflow path specification to an actual
  # file path.  Strings are interpreted literally but symbols are
  # first resolved to the paths they represent.
  #
  #   IMW.add_path :foo, '~/whoa'
  #   IMW.path_to :foo, 'my_thing'
  #   => '~/whoa/my_thing'
  #
  # @param [String, Symbol] pathsegs the path segments to join
  # @return [String] the resulting expanded path
  def self.path_to *pathsegs
    path = Pathname.new IMW.path_to_helper(*pathsegs)
    path.absolute? ? File.expand_path(path) : path.to_s
  end

  # Adds a symbolic path for expansion by +path_to+.
  # 
  #   IMW.add_path :foo, '~/whoa'
  #   IMW.add_path :bar, :foo,   'baz'
  #   IMW.path_to :bar
  #   => '~/whoa/baz'
  #
  # @param [Symbol] sym the name of the path to store
  # @param [Symbol, String] pathsegs the path segments to use to define the path to the name
  # @return [String] the resulting path
  def self.add_path sym, *pathsegs
    IMW::PATHS[sym] = pathsegs.flatten
    path_to[sym]
  end

  # Removes a symbolic path for expansion by +path_to+.
  #
  # @param [Symbol] sym the stored path symbol to remove
  def self.remove_path sym
    IMW::PATHS.delete sym if IMW::PATHS.include? sym
  end

  protected
  def self.path_to_helper *pathsegs # :nodoc:
    # +path_to_helper+ handles the recursive calls for +path_to+.
    expanded = pathsegs.flatten.compact.map do |pathseg|
      case
      when pathseg.is_a?(Symbol) && IMW::PATHS.include?(pathseg) then path_to(IMW::PATHS[pathseg])          
      when pathseg.is_a?(Symbol)                                 then raise IMW::PathError.new("No path expansion set for #{pathseg.inspect}")
      else pathseg
      end
    end
    File.join(*expanded)
  end
end
