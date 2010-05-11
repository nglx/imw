module IMW
  module Resources
    module Schemes

      # Defines methods for reading and writing data to/from an
      # HDFS[http://hadoop.apache.org/common/docs/current/hdfs_design.html]]
      #
      # Learn more about Hadoop[http://hadoop.apache.org] and the
      # {Hadoop Distributed
      # Filesystem}[http://hadoop.apache.org/common/docs/current/hdfs_design.html].
      module HDFS

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
          IMW::Transforms::Transferer.new(:cp, self, new_uri).transfer!
        end

        # Move this resource to the +new_uri+.
        #
        # @param [String, IMW::Resource] new_uri
        # @return [IMW::Resource] the new resource
        def mv new_uri
          IMW::Transforms::Transferer.new(:mv, self, new_uri).transfer!
        end
        
        # Does this path exist on the HDFS?
        #
        # @return [true, false]
        def exist?
          HDFS.fs(:ls, dirname).each do |line|
            return true if line.ends_with?(path)
          end
          false
        end
        alias_method :exists?, :exist?

        # Delete this resource from the HDFS.
        #
        # @option options :skip_trash
        def rm options={}
          args = [:rm]
          args << '-skipTrash' if options[:skip] || options[:skip_trash] || options[:skipTrash]
          args << path
          HDFS.fs(*args)
          self
        end
        alias_method :rm!, :rm

        # Return the size (in bytes) of this resource on the HDFS.
        #
        # @return [Fixnum]
        def size
          HDFS.fs(:du, path).each do |line|
            return $1.to_i if line =~ /^(\d+)/
          end
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
          output = `#{executable} fs -#{command} #{args.compact.map(&:to_str).join(' ')}`.chomp
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
          @executable ||= `which hadoop`.chomp
        end
        
      end
    end
  end
end

