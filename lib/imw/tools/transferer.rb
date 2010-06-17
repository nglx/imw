module IMW
  module Tools

    # A class to encapsulate transferring a resource from one URI to
    # another.
    class Transferer

      # The action this Transferer is to take.
      #
      # @return [:cp, :mv]
      attr_reader :action

      # Set the action of this Transferer.
      #
      # Will raise an error unless +the_action+ is <tt>:cp</tt> or
      # <tt>:mv</tt>.
      #
      # @param [:cp, :mv] the_action
      def action= the_action
        @action = case the_action.to_sym
        when :cp, :copy       then :cp
        when :mv, :move, :mv! then :mv
        else raise IMW::ArgumentError.new("action (#{the_action}) must be one of `cp' (or `copy') or `mv' (or `move' or `mv!'")
        end
      end

      # The source resource.
      #
      # @return [IMW::Resource]
      attr_reader :source

      # Set the source for this transferer.
      #
      # If +the_source+ is local, will check that it exists and raise
      # an error if not.
      #
      # @param [String, IMW::Resource] the_source
      def source= the_source
        s = IMW.open(the_source)
        s.should_exist!("Cannot #{action_verb}") if s.is_local?
        @source = s
      end
      
      # The destination resource.
      #
      # @return [IMW::Resource]
      attr_reader :destination

      # Set the destination for this transferer.
      #
      # If +the_destination+ is local, will check that its parent
      # directory exists and raise an error if not.
      def destination= the_destination
        d = IMW.open(the_destination)
        d.dir.should_exist!("Cannot #{action_verb}") if d.is_local?
        @destination = d
      end

      # Instantiate a new transferer to take the given +action+ on
      # +source+ and +destination+.
      #
      # @param [:cp, :mv] action the action to take
      # @param [String, IMW::Resource] source
      # @param [String, IMW::Resource] destination      
      def initialize action, source, destination
        self.action      = action
        self.source      = source
        self.destination = destination
        raise IMW::PathError.new("Source and destination have the same URI: #{source}") if source.uri.to_s == destination.uri.to_s
      end

      # Transfer source to destination.
      #
      # For local transfer, will raise errors unless the necessary
      # paths exist.
      def transfer!
        IMW.announce_if_verbose("#{action_gerund.capitalize} #{source} to #{destination}")
        send(transfer_method)
        destination.reopen
      end

      protected

      # Return the name of the method that should be used to transfer
      # +source+ to +destination+.
      #
      # @return [String]
      def transfer_method
        source_scheme      = source.is_local?      ? 'file' : source.scheme
        destination_scheme = destination.is_local? ? 'file' : destination.scheme
        method = "#{source_scheme}_to_#{destination_scheme}"
        raise IMW::NoMethodError.new("Do not know how to #{action_verb} #{source} to #{destination}") unless respond_to?(method)
        method
      end

      def action_verb # :nodoc
        action == :cp ? "copy" : "move"
      end

      def action_gerund # :nodoc
        action == :cp ? "copying" : "moving"
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
