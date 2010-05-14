module IMW
  module Schemes
    module Local

      # Defines methods appropriate for any file (or directory) on the
      # local machine.  Includes methods from the File class like
      # File#exist?, File#size, &c.
      #
      # When extending with this module, it will automatically also
      # extend with either IMW::Schemes::Local::LocalDirectory or
      # IMW::Schemes::Local::LocalFile, as appropriate.
      module Base

        def self.extended obj
          # also extend with file or directory as appropriate
          if obj.directory?
            obj.extend(LocalDirectory)
          else
            obj.extend(LocalFile)
          end
        end
        
        # Steal a bunch of class methods from File which only take a
        # path as a first argument.
        [:executable?, :executable_real?, :exist?, :file?, :directory?, :ftype, :owned?, :pipe?, :readable?, :readable_real?, :setgid?, :setuid?, :size, :size?, :socket?, :split, :stat, :sticky?, :writable?, :writable_real?, :zero?].each do |class_method|
          define_method class_method do
            File.send(class_method, path)
          end
        end
        alias_method :exists?, :exist?

        # Return the path to this local object.
        #
        # @return [String]
        def path
          @path ||= File.expand_path(@encoded_uri ? Addressable::URI.decode(uri.to_s) : uri.to_s)
        end

        # Is this file on the local machine?
        #
        # @return [true, false]
        def is_local?
          true
        end

        # Copy this resource to the +new_uri+.
        #
        # @param [String, IMW::Resource] new_uri
        # @return [IMW::Resource] the new resource
        def cp new_uri
          IMW::Tools::Transferer.new(:cp, self, new_uri).transfer!
        end

        # Move this resource to the +new_uri+.
        #
        # @param [String, IMW::Resource] new_uri
        # @return [IMW::Resource] the new resource
        def mv new_uri
          IMW::Tools::Transferer.new(:mv, self, new_uri).transfer!
        end
        
      end

      # Defines methods for appropriate for a local file.
      module LocalFile

        # Is this resource a regular file?
        #
        # @return [true, false]
        def is_file?
          true
        end

        # Delete this resource.
        def rm
          should_exist!("Cannot delete")
          FileUtils.rm path
          self
        end
        alias_method :rm!, :rm

        # Return the IO object at this path.
        #
        # @return [File]
        def io
          @io ||= open(path, mode)
        end

        # Read from this file.
        #
        # @param [Fixnum] length bytes to read
        # @return [String]
        def read length=nil
          io.read(length)
        end

        # Write to this file
        #
        # @param [String, #to_s] text text to write
        # @return [Fixnum] bytes written
        def write text
          io.write text
        end

        # Return the lines in this file.
        #
        # If passed a block, yield each line of the file to the block.
        #
        # @yield [String] each line of the file
        # @return [Array] the lines in the file
        def load &block
          if block_given?
            io.each do |line|
              yield line
            end
          else
            read.split("\n")
          end
        end

        # Map over the lines in this file.
        #
        # @yield [String] each line of the file
        def map &block
          io.map(&block)
        end

        # Dump +data+ into this file.
        #
        # @param [String, Array, #each] data object to dump
        # @option options [true, false] :persist (false) Don't close the file after writing
        def dump data, options={}
          data.each do |element|  # works if data is an Array or a String
            io.puts(element.to_s)
          end
          io.close unless options[:persist]
        end
      end

      # Defines methods for manipulating the contents of a local
      # directory.
      module LocalDirectory

        # Is this resource a directory?
        #
        # @return [true, false]
        def is_directory?
          true
        end

        # Delete this directory.
        #
        # @return [IMW::Resource] the deleted directory
        def rmdir
          FileUtils.rmdir path
          self
        end

        # Delete this directory recursively.
        #
        # @return [IMW::Resource] the deleted directory
        def rm_rf
          FileUtils.rm_rf path
          self
        end

        # Return a list of paths relative to this directory which match
        # the +selector+.  Works just like Dir[].
        #
        # @param [String] selector
        # @return [Array] the matched paths
        def [] selector='*'
          Dir[File.join(path, selector)]
        end

        # Return a list of all paths directly within this directory.
        #
        # @return [Array]
        def contents
          self['*']
        end

        # Does this directory contain +obj+?
        #
        # @param [String, IMW::Resource] obj
        # @return [true, false]
        def contains? obj
          require 'find'
          obj_path = obj.is_a?(String) ? obj : obj.path
          Find.find(path) do |sub_path|
            return true if sub_path.ends_with?(obj_path)
          end
          false
        end

        # Return all paths within this directory, recursively.
        #
        # @return [Array<String>]
        def all_contents
          self['**/*']
        end

        # Return all resources within this directory, i.e. - all paths
        # converted to IMW::Resource objects.
        #
        # @return [Array<IMW::Resource>]
        def resources
          all_contents.map do |path|
            IMW.open(path) unless File.directory?(path)
          end.compact
        end

      end
    end
  end
end



