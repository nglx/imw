#
# h2. lib/imw/utils/config.rb -- configuration parsing
#
# == About
#
# This Config module defined here is responsible for parsing
# configuration files into useful data structures.
#
# Author::    (Philip flip Kromer, Dhruv Bansal) for Infinite Monkeywrench Project (mailto:coders@infochimps.org)
# Copyright:: Copyright (c) 2008 infochimps.org
# License::   GPL 3.0
# Website::   http://infinitemonkeywrench.org/
# 

require 'yaml'

module IMW

  module Config
    # The `etc/directories.yaml' file contains path information for
    # IMW directories in a format that needs to be interpreted here.
    # See the documentation for that file for complete details.
    #
    # In short, directories with a leading '/' are resolved relative
    # to the root of the local filesystem and directories without a
    # leading '/' are resolved relative to the IMW_ROOT which is
    # declared either as an environment variable or in the
    # `directories.yaml' file itself.
    #
    # Directories with a leading protocol statement (ssh:, ftp:, etc.)
    # must be suitably interpreted as well...

    # The `raw_directories' gotten from the configuration file will
    # have to be interpreted properly into Directories
    raw_directories = YAML::load_file(File.expand_path(File.dirname(__FILE__) + "/../../../etc/directories.yaml"))
    Directories = {}

    # find the IMW_ROOT -- environment variable takes precedence over
    # value in configuration file!
    if ENV['IMW_ROOT'] then
      imw_root = File.expand_path(ENV['IMW_ROOT'])
    else
      imw_root = File.expand_path(raw_directories['IMW_ROOT'])
    end
    if !imw_root then
      raise "No root directory for IMW specified!  Set `IMW_ROOT' environment variable or edit etc/directories.yaml"
    else
      Directories[:imw_root] = imw_root
    end

    # This method interprets the string for each directory path,
    # implementing the logic outlined above in and
    # `etc/directories.yaml'.
    def self.interpret_directory(directory)
      if directory =~ /^\// then
        directory
      elsif directory =~ /^[a-zA-Z]+:/
        raise NotImplementedError.new("Directories with prefixes like `ssh:' or `ftp:' are not currently implemented in IMW.  Sorry!")
      else
        [Directories[:imw_root],directory].join('/')
      end
    end

    # Start interpreting the directories (this should be written more
    # cleverly to allow for the structure of the directories.yaml file
    # to be changed...)
    Directories[:ripd] = interpret_directory(raw_directories['workflow']['ripd'])
    Directories[:xtrd] = interpret_directory(raw_directories['workflow']['xtrd'])
    Directories[:mungd] = interpret_directory(raw_directories['workflow']['mungd'])
    Directories[:fixd] = interpret_directory(raw_directories['workflow']['fixd'])
    Directories[:pkgd] = interpret_directory(raw_directories['workflow']['pkgd'])
    Directories[:dump] = interpret_directory(raw_directories['workflow']['dump'])
    Directories[:process] = interpret_directory(raw_directories['process'])
    Directories[:data] = interpret_directory(raw_directories['data'])

    # Here there needs to be section which parses the `taxonomy'
    # section of the `etc/directories.yaml' file to deal with
    # per-category exceptions to the directory rules outlined above.
    
  end

end



# puts "#{File.basename(__FILE__)}: Something clever" # at bottom