module IMW
  module Resources
    module Schemes

      # Defines methods for accessing a resource over HTTP.  Uses
      # RestClient to implement the basic HTTP verbs (GET, POST, PUT,
      # DELETE, HEAD).
      module HTTP

        # Is this resource being accessed via HTTP?
        #
        # @return [true, false]
        def via_http?
          true
        end

        # Copy this resource to the +new_uri+.
        #
        # @param [String, IMW::Resource] new_uri
        # @return [IMW::Resource] the new resource
        def cp new_uri
          IMW::Transforms::Transferer.new(:cp, self, new_uri).transfer!
        end
        

        # Return the basename of the URI or <tt>_index</tt> if it's
        # blank, as in the case of <tt>http://www.google.com</tt>.
        #
        # @return [String]
        def effective_basename
          (basename.blank? || basename =~ %r{^/*$}) ? "_index" : basename
        end

        # Send a GET request to this resource's URI.
        #
        # If the response doesn't have HTTP code 2xx, a RestClient
        # error will be raised.
        #
        # If a block is given then the response will be passed to the
        # block, even in case of a non-2xx code.
        #
        # See the documentation for
        # RestClient[http://rdoc.info/projects/archiloque/rest-client]
        # for more information.
        #
        # @param [Hash] headers the headers to include in the request
        # @yield [RestClient::Response] the response from the server
        # @return [RestClient::Response] the response from the server
        # @raise [RestClient::NotModified, RestClient::Unauthorized, RestClient::ResourceNotFound, RestClient::RequestFailed] error from RestClient on non-2xx response codes
        def get headers={}, &block
          make_restclient_request do
            RestClient.get(uri.to_s, headers, &block)
          end
        end

        # Send a POST request to this resource's URI with data
        # +payload+.
        #
        # If the response doesn't have HTTP code 2xx, a RestClient
        # error will be raised.
        #
        # If a block is given then the response will be passed to the
        # block, even in case of a non-2xx code.
        #
        # See the documentation for
        # RestClient[http://rdoc.info/projects/archiloque/rest-client]
        # for more information.
        #
        # @param [Hash, String] payload the data to send
        # @param [Hash] headers the headers to include in the request
        # @yield [RestClient::Response] the response from the server
        # @return [RestClient::Response] the response from the server
        # @raise [RestClient::NotModified, RestClient::Unauthorized, RestClient::ResourceNotFound, RestClient::RequestFailed] error from RestClient on non-2xx response codes
        def post payload, headers={}, &block
          make_restclient_request do
            RestClient.post(uri.to_s, payload, headers, &block)
          end
        end

        # Send a PUT request to this resource's URI with data
        # +payload+.
        #
        # If the response doesn't have HTTP code 2xx, a RestClient
        # error will be raised.
        #
        # If a block is given then the response will be passed to the
        # block, even in case of a non-2xx code.
        #
        # See the documentation for
        # RestClient[http://rdoc.info/projects/archiloque/rest-client]
        # for more information.
        #
        # @param [Hash, String] payload the data to send
        # @param [Hash] headers the headers to include in the request
        # @yield [RestClient::Response] the response from the server
        # @return [RestClient::Response] the response from the server
        # @raise [RestClient::NotModified, RestClient::Unauthorized, RestClient::ResourceNotFound, RestClient::RequestFailed] error from RestClient on non-2xx response codes
        def put payload, headers={}, &block
          make_restclient_request do
            RestClient.put(uri.to_s, payload, headers, &block)
          end
        end
        
        # Send a DELETE request to this resource's URI.
        #
        # If the response doesn't have HTTP code 2xx, a RestClient
        # error will be raised.
        #
        # If a block is given then the response will be passed to the
        # block, even in case of a non-2xx code.
        #
        # See the documentation for
        # RestClient[http://rdoc.info/projects/archiloque/rest-client]
        # for more information.
        #
        # @param [Hash] headers the headers to include in the request
        # @yield [RestClient::Response] the response from the server
        # @return [RestClient::Response] the response from the server
        # @raise [RestClient::NotModified, RestClient::Unauthorized, RestClient::ResourceNotFound, RestClient::RequestFailed] error from RestClient on non-2xx response codes
        def delete headers={}, &block
          make_restclient_request do
            RestClient.delete(uri.to_s, headers, &block)
          end
        end
        
        # Send a HEAD request to this resource's URI.
        #
        # If the response doesn't have HTTP code 2xx, a RestClient
        # error will be raised.
        #
        # If a block is given then the response will be passed to the
        # block, even in case of a non-2xx code.
        #
        # See the documentation for
        # RestClient[http://rdoc.info/projects/archiloque/rest-client]
        # for more information.
        #
        # @param [Hash] headers the headers to include in the request
        # @yield [RestClient::Response] the response from the server
        # @return [RestClient::Response] the response from the server
        # @raise [RestClient::NotModified, RestClient::Unauthorized, RestClient::ResourceNotFound, RestClient::RequestFailed] error from RestClient on non-2xx response codes
        def head headers={}, &block
          make_restclient_request do
            RestClient.head(uri.to_s, headers, &block)
          end
        end

        protected
        def make_restclient_request &block # :nodoc
          require 'restclient'
          begin
            yield
          rescue RestClient::NotModified, RestClient::Unauthorized, RestClient::ResourceNotFound, RestClient::RequestFailed => e
            raise IMW::NetworkError.new("#{e.class} -- #{e.message}")
          end
        end
      end
    end
  end
end

