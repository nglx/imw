module IMW
  module Tools
    class Transferer

      attr_accessor :action, :source, :destination
      
      def initialize action, source, destination
        @action      = normalize_action(action)
        @source      = IMW.open(source)
        @destination = IMW.open(destination)
        raise IMW::PathError.new("Source and destination have the same URI: #{@source.uri}") if @source.uri.to_s == @destination.uri.to_s
      end

      # Transfer source to destination.
      #
      # For local transfer, will raise errors unless the necessary
      # paths exist.
      def transfer!
        if source.is_local? 
          source.should_exist!("Cannot #{action}") 
          source_scheme = 'file'                   
        else
          source_scheme = source.scheme
        end
        
        if destination.is_local?
          destination.dir.should_exist!("Cannot #{action}")          
          destination_scheme = 'file'
        else
          destination_scheme = destination.scheme
        end
        
        method             = "#{source_scheme}_to_#{destination_scheme}"
        
        if respond_to?(method)
          send(method)
        else
          raise IMW::NoMethodError.new("Do not know how to #{action} #{source.uri} => #{destination.uri} (#{source_scheme.inspect} => #{destination_scheme.inspect})")
        end
        destination.reopen
      end

      protected

      def normalize_action action # :nodoc:
        case action.to_sym
        when :cp, :copy then :cp
        when :mv, :move, :mv! then :mv
        else raise IMW::ArgumentError.new("action (#{action}) must be one of `cp' (or `copy') or `mv' (or `move' or `mv!'")
        end
      end

      #
      # Purely local file
      #

      def file_to_file
        fu_action = (action == :cp && source.is_directory?) ? :cp_r : action
        FileUtils.send(fu_action, source.path, destination.path)
      end

      #
      # HTTP
      #

      def http_to_file
        File.open(destination.path, 'w') { |f| f.write(source.read) }
      end

      #
      # S3
      #

      def file_to_s3
        IMW::Schemes::S3.put(source, destination)
      end

      def http_to_s3
        IMW::Schemes::S3.put(source, destination)
      end

      def s3_to_file
        IMW::Schemes::S3.get(source, destination)
      end

      def s3_to_s3
        IMW::Schemes::S3.copy(source, destination)
      end

      #
      # HDFS
      #

      def hdfs_to_hdfs
        IMW::Schemes::HDFS.fs(action, source.path, destination.path)
      end

      def file_to_hdfs
        IMW::Schemes::HDFS.fs(:put, source.path, destination.path)
      end

      def hdfs_to_file
        IMW::Schemes::HDFS.fs(:get, source.path, destination.path)
      end

      def s3_to_hdfs
        IMW::Schemes::HDFS.fs(action, source.s3n_url, destination.path)
      end

      def hdfs_to_s3
        IMW::Schemes::HDFS.fs(action, source.path, destination.s3n_url)
      end

    end
  end
end
