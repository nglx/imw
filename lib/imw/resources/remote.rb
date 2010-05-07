module IMW
  module Resources

    # Defines methods appropriate for accessing a remote resource, no
    # matter what the protocol.
    module RemoteObj

      #
      # TODO -- self.extended should extend by RemoteDirectory when appropriate
      #
      
      def self.extended obj
        obj.extend(RemoteFile)
      end

      
    end
    
    module RemoteFile

      # Copy the remote resource to the +local_path+.
      #
      # @param [String, IMW::Resource] local_path
      # @return [IMW::Resource] the local file
      def cp local_path
        returning(IMW.open(IMW.local_path(local_path))) do |local_obj|
          File.open(local_obj.path, 'w') { |f| f.write(read) }
        end
      end

      # Copy the remote resource to a local file in +dir+ with the
      # same basename as the resource.
      #
      # @param [String, IMW::Resource] dir
      # @return [IMW::Resource]
      def cp_to_dir dir
        cp(File.join(IMW.local_path(dir), effective_basename))
      end
      
      # Return the IO object for this remote file.
      #
      # The mode of this resource is ignored.
      #
      # @return [StringIO]
      def io
        require 'open-uri'
        @io ||= open(uri.to_s)              # ignore mode
      end

      # Read the contents of this remote file.
      #
      # @return [String]
      def read
        io.read
      end

      # Return the lines of this remote file.
      #
      # If passed a block then yield each line to the block.
      #
      # @return [Array] the lines of this remote file
      # @yield [String] each line of this remote file
      def load &block
        if block_given?
          io.each do |line|
            yield line
          end
        else
          read.split("\n")
        end
      end

      # Map over the lines in this remote file.
      #
      # @yield [String] each line of the file
      def map &block
        io.map(&block)
      end
    end


    module RemoteDirectory

      #
      # TODO -- bloody everything
      #

      
    end
  end
end

