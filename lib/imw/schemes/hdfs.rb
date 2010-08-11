module IMW
  module Schemes

    # Defines methods for reading and writing data to/from an
    # HDFS[http://hadoop.apache.org/common/docs/current/hdfs_design.html]]
    #
    # Learn more about Hadoop[http://hadoop.apache.org] and the
    # {Hadoop Distributed
    # Filesystem}[http://hadoop.apache.org/common/docs/current/hdfs_design.html].
    module HDFS

      # Checks to see if this is a file or directory
      def self.extended obj
        obj.extend(obj.is_directory? ? HDFSDirectory : HDFSFile)
      end

      # Is this resource an HDFS resource?
      #
      # @return [true, false]
      def on_hdfs?
        true
      end
      alias_method :is_hdfs?, :on_hdfs?

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

      # Delete this resource from the HDFS.
      #
      # @option options [true,false] :skip_trash
      def rm options={}
        should_exist!("Cannot delete.")
        args = [:rm]
        args << '-skipTrash' if options[:skip] || options[:skip_trash] || options[:skipTrash]
        args << path
        HDFS.fs(*args)
        self
      end
      alias_method :rm!, :rm
      
      
      # Does this path exist on the HDFS?
      #
      # @return [true, false]
      def exist?
        return @exist unless @exist.nil?
        refresh!
        @exist
      end
      alias_method :exists?, :exist?


      # Return the size (in bytes) of this resource on the HDFS.
      #
      # This value is cached.  Call +refresh+ to refresh the cache
      # manually.
      #
      # @return [Fixnum]
      def size
        return @size unless @size.nil?
        refresh!
        should_exist!("Cannot report size")
        @size
      end

      # Return the number of directories contained at or below this
      # path on the HDFS.
      #
      # This value is cached.  Call +refresh+ to refresh the cache
      # manually.
      #
      # @return [Fixnum]
      def num_dirs
        return @num_dirs unless @num_dirs.nil?
        refresh!
        should_exist!("Cannot report number of directories.")
        @num_dirs
      end

      # Return the number of files contained at or below this path
      # on the HDFS.
      #
      # This value is cached.  Call +refresh+ to refresh the cache
      # manually.
      #
      # @return [Fixnum]
      def num_files
        return @num_files unless @num_files.nil?
        refresh!
        should_exist!("Cannot report number of files.")
        @num_files
      end

      # Is this resource an HDFS directory?
      #
      # @return [true, false]
      def is_directory?
        exist? && num_dirs > 0
      end

      # Refresh the cached file properties.
      #
      # @return [IMW::Resource] this resource
      def refresh!
        response = HDFS.fs(:count, path)
        if response.blank? || response =~ /^Can not find listing for/
          @exist = false
          @num_dirs, @num_files, @size, @hdfs_path = false, false, false, false
        else
          @exist = true
          parts = response.split
          @num_dirs, @num_files, @size = parts[0..2].map(&:to_i)
          @hdfs_path = parts.last
        end
        self
      end

      # Execute +command+ with +args+ on the Hadoop Distributed
      # Filesystem (HDFS).
      #
      # If passed a block, yield each line of the output from the
      # command, else just return the output.
      #
      # Try running `hadoop fs -help' for more information.
      #
      # @param [String, Symbol] command the command to run.
      # @param [String, Symbol] args the arguments to pass the command
      # @yield [String] each line of the command's output
      # @return [String] the command's output
      def self.fs command, *args
        command_string = "#{executable} fs -#{command} #{args.compact.map(&:to_str).join(' ')}"
        command_string += " 2>&1" if command == :count # FIXME or else it just spams the screen when we do HDFS#refresh!
        output = `#{command_string}`.chomp
        if block_given?
          output.split("\n").each do |line|
            yield line
          end
        else
          output
        end
      end

      protected
      # Returns the path to the Hadoop executable.
      #
      # @return [String]
      def self.executable
        @executable ||= begin
                          string = `which hadoop`.chomp
                          raise IMW::Error.new("Could not find hadoop command.  Is Hadoop installed?") if string.blank?
                          string
                        end
      end
    end

    # Defines methods for reading data from HDFS files.
    module HDFSFile

      # Return the contents of this HDFS file as a string.
      #
      # Be VERY careful how you use this!
      #
      # @return [String]
      def read
        HDFS.fs(:cat, path)
      end

      # Iterate through each line of this HDFS resource.
      #
      # @yield [String] each line of the file
      def each &block
        HDFS.fs(:cat, path, &block)
      end

      # Return a handle on a StringIO object representing the
      # content in this HDFS file.
      #
      # Be VERY careful how you use this!  It is a StringIO object
      # so the whole HDFS file is read into a string before
      # returning the handle.
      #
      # @return [StringIO]
      def io
        @io ||= StringIO.new(read)
      end

      # Map over the lines of this HDFS resource.
      #
      # @yield [String] each line of the file
      # @return [Array] the result of the block on each line
      def map &block
        returning([]) do |output|
          HDFS.fs(:cat, path) do |line|
            output << block.call(line)
          end
        end
      end

    end

    # Defines methods for listing contents of HDFS directories.
    module HDFSDirectory

      # Return the paths of all files and directories directly below
      # this directory on the HDFS.
      #
      # @return [Array<String>]
      def contents
        returning([]) do |paths|
          HDFS.fs(:ls, path) do |line|
            next if line =~ /^Found.*items$/
            paths << line.split.last
          end
        end
      end

      # Return the resources directly below this directory on the
      # HDFS.
      #
      # @return [Array<IMW::Resource>]
      def resources
        contents.map { |path| IMW.open(path) }
      end

      # Return the resource at the base path of this resource joined
      # to +path+.
      #
      #   IMW.open('hdfs:///path/to/dir').join('subdir')
      #   #=> IMW::Resource at 'hdfs:///path/to/dir/subdir'
      #
      # @param [Array<String>] paths
      # @return [IMW::Resource]
      def join *paths
        IMW.open(File.join(stripped_uri.to_s, *paths))
      end
    end
  end
end
