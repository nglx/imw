module IMW
  module Schemes

    # Contains modules which define methods appropriate for remote
    # resources, no matter the protocol.
    module Remote

      # Defines methods appropriate for accessing a remote resource,
      # no matter the protocol.
      module Base
        
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

        # Return the resource at the base path of this resource joined
        # to +path+.
        #
        #   IMW.open('http://example.com/path/to/dir').join('subdir')
        #   #=> IMW::Resource at 'http://example.com/path/to/dir/subdir'
        #
        # @param [Array<String>] paths
        # @return [IMW::Resource]
        def join *paths
          IMW.open(File.join(stripped_uri.to_s, *paths))
        end

        #
        # TODO -- bloody everything.  what's the best way to tell if
        # the remote URL is a directory?
        #

        
      end
    end
  end
end
