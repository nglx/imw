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

      # Is this resource on a remote host?
      #
      # @return [true,false]
      def is_remote?
        true
      end

      # The host of this resource.
      #
      # @return [String]
      def host
        @host ||= uri.host
      end

      # Return the query string part of this resource's URI.  Will
      # likely be +nil+ for local resources.
      #
      # @return [String]
      def query_string
        @query_string ||= uri.query
      end

      # Return the fragment part of this resource's URI.  Will likely be
      # +nil+ for local resources.
      #
      # @return [String]
      def fragment
        @fragment ||= uri.fragment
      end

      # Return the path part of this resource's URI.  Will _not_
      # include the +query_string+ or +fragment+.
      #
      # @return [String]
      def path
        @path ||= uri.path
      end

    end
    
    module RemoteFile

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

