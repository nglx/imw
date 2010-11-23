module IMW
  module Schemes

    # Defines methods for reading and writing data from an FTP server.
    #
    #   IMW.open('ftp://user:pass@my_bucket/path/to/some/file.csv')
    #
    # Learn more about {Amazon Web Services}[http://aws.amazon.com].
    module FTP

      module Base

      # Is this resource an FTP resource?
      #
      # @return [true, false] 
      def on_ftp?
        true
      end
      alias_method :is_ftp?, :on_ftp?

      # Copy this resource to the +new_uri+.
      #
      # @param [String, IMW::Resource] new_uri
      # @return [IMW::Resource] the new resource
      def cp new_uri
        local_obj = IMW.open(new_uri)
        raise IMW::PathError.new("FTP resources (#{self}) can only be downloaded to a local path") unless local_obj.is_local?
        local_obj.dir.should_exist!
        FTP.open(host, user, password) do |ftp|
          ftp.get(path, local_obj.path)
        end
        local_obj
      end

      # Does this resource exist on S3?
      #
      # @return [true, false]
      def exist?
        s3_object.exists?
      end
      alias_method :exists?, :exist?

      # Remove this resource from S3.
      #
      # @return [IMW::Resource] the deleted object
      def rm
        s3_object.delete
      end
      alias_method :rm!, :rm

      # Return the S3N URL for this S3 object
      #
      #   resource = IMW.open('s3://my_bucket/path/to/some/obj')
      #   resource.s3n_url
      #   => 's3n://my_bucket/path/to/some/obj'
      #
      # @return [String]
      def s3n_url
        uri.to_s.gsub(/^s3:/, 's3n:')
      end

      # Return the contents of this S3 object.
      #
      # @return [String]
      def read
        s3_object.value
      end

      # Store +source+ into +destination+.
      # 
      # @param [String, IMW::Resource, #io] source
      # @param [String, IMW::Resource, #path, #bucket] destination
      # @return [IMW::Resource] the new S3 object
      def self.put source, destination
        source       = IMW.open(source)
        destintation = IMW.open(destination)
        raise IMW::ArgumentError.new("destination must be on S3 -- #{destination} given") unless destination.on_s3?
        make_connection!
        AWS::S3::S3Object.store(destination.path, source.io, destination.bucket)
        destination
      end

      # Download +source+ from S3 into +destination+.
      #
      # @param [String, IMW::Resource, #path, #bucket] source
      # @param [String, IMW::Resource, #write] destination
      # @return [IMW::Resource] the new resource
      def self.get source, destination
        source      = IMW.open(source)
        destination = IMW.open!(destination)
        raise IMW::ArgumentError.new("source must be on S3 -- #{source} given") unless source.on_s3?
        make_connection!
        AWS::S3::S3Object.stream(source.path, source.bucket) do |chunk|
          destination.write(chunk)
        end
        destination.close
        destination.reopen
      end

      # Copy S3 resource +source+ to +destination+.
      #
      # @param [String, IMW::Resource, #path, #bucket] source
      # @param [String, IMW::Resource, #path, #bucket] destination
      # @return [IMW::Resource] the new resource
      def self.copy source, destination
        source      = IMW.open(source)
        destination = IMW.open(destination)
        raise IMW::PathError.new("Bucket names must be non-blank and match to 'copy'") unless source.bucket.present? && destination.bucket.present? && source.bucket == destination.bucket
        make_connection!
        AWS::S3::Object.copy(source.path, destination.path, destination.bucket)
        destination
      end

      # Return the resource at the base path of this resource joined
      # to +path+.
      #
      #   IMW.open('s3:://bucket/path/to/dir').join('subdir')
      #   #=> IMW::Resource at 's3://bucket/path/to/dir/subdir'
      #
      # @param [Array<String>] paths
      # @return [IMW::Resource]
      def join *paths
        IMW.open(File.join(stripped_uri.to_s, *paths))
      end

      protected
      # Make an S3 connection.
      #
      # Uses settings defined in IMW::AWS_CREDENTIALS.
      #
      # @return [AWS
      def self.make_connection!
        return @connection if @connection
        raise IMW::Error.new("Must define a constant IMW::AWS_CREDENTIALS with an :access_key_id and a :secret_access_key before using S3 resources") unless defined?(IMW::AWS_CREDENTIALS)
        require 'aws/s3'
        @connection = AWS::S3::Base.establish_connection!(IMW::AWS_CREDENTIALS)
      end
      
    end
  end
end
