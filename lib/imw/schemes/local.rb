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

        # Return the directory of this resource.
        #
        # @return [IMW::Resource]
        def dir
          IMW.open(dirname)
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

        # Emit +data+ into this file.
        #
        # @param [String, Array, #each] data object to emit
        # @option options [true, false] :persist (false) Don't close the file after writing
        def emit data, options={}
          data.each do |element|  # works if data is an Array or a String
            io.puts(element.to_s)
          end
          io.close unless options[:persist]
        end

        # Return a summary of properties of this local file.
        #
        # Returned properties include
        # - basename
        # - size
        # - extension
        # - snippet
        def summary
          data = {
            :basename  => basename,
            :size      => size,
            :extension => extension
          }
          if respond_to?(:snippet)
            data[:snippet] = snippet
          end
          if respond_to?(:schema)
            data[:schema] = schema
          end
          data
        end
        
      end

      # Defines methods for manipulating the contents of a local
      # directory.
      module LocalDirectory

        # Explicitly set the path to the schemata for this directory.
        attr_writer :schemata_path

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
        alias_method :rmdir!, :rmdir

        # Delete this directory recursively.
        #
        # @return [IMW::Resource] the deleted directory
        def rm_rf
          FileUtils.rm_rf path
          self
        end
        alias_method :rm_rf!, :rm_rf

        # Return a list of paths relative to this directory which match
        # the +selector+.  Works just like Dir[].
        #
        # @param [String] selector
        # @return [Array] the matched paths
        def [] selector='*'
          Dir[File.join(path, selector)]
        end

        # Does this directory contain +obj+?
        #
        # @param [String, IMW::Resource] obj
        # @return [true, false]
        def contains? obj
          obj = IMW.open(obj)
          return false unless obj.is_local?
          return true  if obj.path == path
          return false unless obj.path.starts_with?(path)
          return true  if self[obj.path[path.length..-1]].size > 0
          false
        end

        # Return a list of all paths directly within this directory.
        #
        # @return [Array<String>]
        def contents
          self['*']
        end

        # Return all paths within this directory, recursively.
        #
        # @return [Array<String>]
        def all_contents
          self['**/*']
        end

        # Return all resources directly within this directory.
        #
        # @return [Array<IMW::Resource>]
        def resources
          contents.map { |path| IMW.open(path) }
        end

        # Return all resources within this directory, recursively.
        #
        # @return [Array<IMW::Resource>]
        def all_resources
          all_contents.map do |path|
            IMW.open(path) unless File.directory?(path)
          end.compact
        end

        # Package the contents of this directory to an archive at
        # +package_path+.
        #
        # @param [String, IMW::Resource] package_path
        # @return [IMW::Resource] the new package
        def package package_path
          temp_package = IMW.open(File.join(dirname, File.basename(package_path)))
          FileUtils.cd(dirname) { temp_package.create(basename) }
          temp_package.path == File.expand_path(package_path) ? temp_package : temp_package.mv(package_path)
        end
        alias_method :package!, :package

        # Change the working directory to this local directory.
        #
        # If passed a black, execute the block in this directory and
        # then change back to the initial directory.
        #
        # This method works the same as FileUtils.cd.
        def cd &block
          FileUtils.cd(path, &block)
        end

        # Create this directory.
        #
        # No error if the directory already exists.
        #
        # @return [IMW::Resource] this directory
        def create
          FileUtils.mkdir_p(path) unless exist?
          self
        end

        # Return the resource at the base path of this resource joined
        # to +path+.
        #
        #   IMW.open('/path/to/dir').join('subdir')
        #   #=> IMW::Resource at '/path/to/dir/subdir'
        #
        # @param [Array<String>] paths
        # @return [IMW::Resource]
        def join *paths
          IMW.open(File.join(stripped_uri.to_s, *paths))
        end

        # Return a hash summarizing this directory with a key
        # <tt>:contents</tt> containing an array of hashes summarizing
        # this directories contents.
        #
        # The directory summary includes the following information
        # - basename
        # - size
        # - num_files
        # - contents
        #
        # @return [Hash]
        def summary
          {
            :basename  => basename,
            :size      => size,
            :num_files => contents.length,
            :contents  => resources.map do |resource|
              resource.guess_schema! if guess_schema? && resource.respond_to?(:guess_schema!)
              resource_summary = resource.summary
              resource_summary[:schema] = schemata[resource] if schemata && schemata.describe?(resource)
              resource_summary
            end
          }
        end

        # Whether or not to have this directory's resources guess
        # their schema when none is provided.
        #
        # @return [true, false]
        def guess_schema?
          (!! @guess_schema)
        end

        # Force this directory's resources to guess at their schemas.
        #
        # @return [true]
        def guess_schema!
          @guess_schema = true
        end

        # The path at which this directory's schemata file lives.
        #
        # Will default to any file beginning with +schema+ and ending
        # with a +yaml+ or +json+ extension directly in this
        # directory.
        #
        # @return [String, nil]
        def schemata_path
          @schemata_path ||= contents.detect { |path| path =~ /schema.*\.(ya?ml|json)$/ }
        end

        # Does this directory contain a file providing schemata for
        # other files within this directory?
        #
        # @return [true, false]
        def schemata?
          (!! schemata_path)
        end

        # Return the schemata for this directory.
        #
        # @return [IMW::Metadata::Schemata, nil]
        def schemata
          @schemata ||= schemata? && Schemata.load(schemata_path)
        end

      end
    end
  end
end



