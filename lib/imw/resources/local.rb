module IMW
  module Resources

    # Defines methods appropriate for any file (or directory) on the
    # local machine.  Includes methods from the File class like
    # File#exist?, File#size, &c.
    #
    # When extending with this module, it will automatically also
    # extend with either IMW::Resources::LocalDirectory or
    # IMW::Resources::LocalFile, as appropriate.
    module LocalObj

      def self.extended obj
        # also extend with file or directory as appropriate
        obj.extend(obj.directory? ? LocalDirectory : LocalFile)
      end
      
      # Steal a bunch of class methods from File which only take a
      # path as a first argument.
      [:executable?, :executable_real?, :exist?, :file?, :directory?, :ftype, :owned?, :pipe?, :readable?, :readable_real?, :setgid?, :setuid?, :size, :size?, :socket?, :split, :stat, :sticky?, :writable?, :writable_real?, :zero?].each do |class_method|
        define_method class_method do
          File.send(class_method, path)
        end
      end
      alias_method :exists?, :exist?
    end

    # Defines methods for appropriate for a local file.
    module LocalFile

      # Delete this resource.
      def rm
        should_exist!("Cannot delete")
        FileUtils.rm path
      end
      alias_method :rm!, :rm

      # Copy this resource to +new_path+.
      #
      # @param [String] new_path the path to copy the resource to
      # @return [IMW::Resource] the new resource
      def cp new_path
        should_exist!("Cannot copy")
        FileUtils.cp path, IMW.local_path(new_path)
        IMW.open(new_path)
      end

      # Copy this resource to +dir+.
      #
      # @param [String, IMW::Resource] dir the directory to copy the resource to
      # @return [IMW::Resource] the new resource
      def cp_to_dir dir
        cp File.join(IMW.local_path(dir),basename)
      end

      # Move this resource to +new_path+.
      #
      # @param [String] new_path the new path to move the resource to
      # @return [IMW::Resource] the new resource
      def mv new_path
        should_exist!("Cannot move")
        FileUtils.mv path, IMW.local_path(new_path)
        IMW.open(new_path)
      end
      alias_method :mv!, :mv

      # Move this file to +dir+.
      #
      # @param [String, IMW::Resource] dir the directory to move this resource to
      # @return [IMW::Resource] the new resource
      def mv_to_dir dir
        mv File.join(IMW.local_path(dir),basename)
      end
      alias_method :mv_to_dir!, :mv_to_dir

      # Raise an error if this resource doesn't exist.
      #
      # @param [String] message an optional message to include
      def should_exist! message=nil
        raise IMW::PathError.new([message, "#{path} does not exist"].compact.join(', ')) unless exist?
      end

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

      # Is this file an archive?
      #
      # @return [false]
      def archive?
        false
      end

      # Is this file compressed?
      #
      # @return [false]
      def compressed?
        false
      end

      # Is this file compressible?
      #
      # @return [true]
      def compressible?
        true
      end

    end


    module LocalDirectory

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

      # Copy this local directory to +new_path+.
      #
      # @param [String, IMW::Resource] new_path
      # @return [IMW::Resource] the new directory
      def cp new_path
        new_path = IMW.local_path(new_path)
        FileUtils.cp_r path, new_path
        if File.exist?(new_path) && File.directory?(new_path)
          # path was copied beneath new_path
          IMW.open(File.join(new_path, basename))
        else
          IMW.open(new_path)
        end
      end

      # Copy this local directory to a directory of the same name
      # below +dir+
      #
      # @param [String, IMW::Resource] dir
      # @return [IMW::Resource] the new directory
      def cp_to_dir dir
        cp dir
      end

      # Move this local directory to the +new_path+.
      #
      # @param [String, IMW::Resource] new_path
      # @return [IMW::Resource] the new directory
      def mv new_path
        new_path = IMW.local_path(new_path)
        FileUtils.mv path, new_path
        if File.exist?(new_path) && File.directory?(new_path)
          # path was copied beneath new_path
          IMW.open(File.join(new_path, basename))
        else
          IMW.open(new_path)
        end
      end

      # Move this local directory to a directory of the same name
      # below +dir+.
      #
      # @param [String, IMW::Resource] dir
      # @return [IMW::Resource] the new directory
      def mv_to_dir dir
        mv dir
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


