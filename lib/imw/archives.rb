module IMW

  # Contains modules which define the behavior of archive files.
  module Archives

    # Handlers for archives.
    HANDLERS = [
                ["Archives::Tarbz2",     Proc.new { |r| r.is_local? && r.path =~ /\.tar\.bz2$/  } ],
                ["Archives::Tarbz2",     Proc.new { |r| r.is_local? && r.path =~ /\.tbz2$/      } ],
                ["Archives::Targz",      Proc.new { |r| r.is_local? && r.path =~ /\.tar\.gz$/   } ],
                ["Archives::Targz",      Proc.new { |r| r.is_local? && r.path =~ /\.tgz$/       } ],
                ["Archives::Tar",        Proc.new { |r| r.is_local? && r.path =~ /\.tar$/       } ],
                ["Archives::Rar",        Proc.new { |r| r.is_local? && r.path =~ /\.rar$/       } ],
                ["Archives::Zip",        Proc.new { |r| r.is_local? && r.path =~ /\.zip$/       } ]
               ]

    autoload :Rar,    'imw/archives/rar'
    autoload :Tar,    'imw/archives/tar'
    autoload :Tarbz2, 'imw/archives/tarbz2'
    autoload :Targz,  'imw/archives/targz'
    autoload :Zip,    'imw/archives/zip'

    # Defines methods for creating, appending to, extracting, and
    # listing an archive file.  This module isn't used to directly
    # extend an IMW::Resource -- instead, format specifc modules
    # (e.g. - IMW::Resources::Archives::Tarbz2) include this module
    # and define the specific settings (command-line flags, &c.)
    # required to make things work.
    module Base

      attr_accessor :archive_settings

      # Is this file an archive?
      #
      # @return [true, false]
      def is_archive?
        true
      end

      # Create an archive of the given +input_paths+.
      #
      # The input paths must be strings and will be shell-escaped
      # before further processing.  This means you cannot use a shell
      # glob!
      #
      # @param [String] input_paths the paths to add to this archive
      # @return [IMW::Resource] the resutling archive
      def create *input_paths
        should_have_archive_setting!("Cannot create archive #{path}", :program, :create)
        IMW.system archive_settings[:program], archive_settings[:create], path, *input_paths.flatten
        self
      end

      # Append to this archive the given +input_paths+.
      #
      # The input paths must be strings and will be shell-escaped
      # before further processing.  This means you cannot use a shell
      # glob!
      #
      # @param [String] input_paths the paths to add to this archive
      # @return [IMW::Resource] the resutling archive      
      def append *input_paths
        should_have_archive_setting!("Cannot append to archive #{path}", :program, :append)
        IMW.system archive_settings[:program], archive_settings[:append], path, *input_paths.flatten
        self
      end

      # Extract the files from this archive to the current directory.
      #
      # @return [IMW::Resource] this archive
      def extract
        should_exist!("Cannot extract archive.")        
        should_have_archive_setting!("Cannot extract archive #{path}", :extract, [:unarchving_program, :program])
        program = archive_settings[:unarchiving_program] || archive_settings[:program]
        IMW.system program, archive_settings[:extract], path
        self
      end

      # Return a (sorted) list of contents in this archive.
      #
      # @return [Array<String>] a list of paths in the archive.
      def contents
        should_exist!("Cannot list archive contents.")
        should_have_archive_setting!("Cannot list archive #{path}", :list, [:unarchiving_program, :program])
        program = archive_settings[:unarchiving_program] || archive_settings[:program]
        # FIXME this needs to be more robust
        flags = archive_settings[:list]
        flags = flags.join(' ') if flags.is_a?(Array)
        command = [program, flags, path.gsub(' ', '\ ')].join(' ')
        output  = `#{command}`
        archive_contents_string_to_array(output)
      end

      protected

      def should_have_archive_setting! message=nil,*settings # :nodoc:
        settings.each do |setting|
          if setting.is_a?(Array)
            raise IMW::Error.new([message, "Must define one of #{setting.join(', ')} in archive_settings"].compact.join(', ')) unless setting.any? { |optional_setting| archive_settings[optional_setting] }
          else
            raise IMW::Error.new([message, "Must define #{setting} in archive_setings"].compact.join(', '))                    unless archive_settings[setting]
          end
        end
      end

      # Parse and format the output from the archive program's "list"
      # command into an array of filenames.
      #
      # An including class can override this method to match the
      # output from the archiving program of that class.
      #
      # @param [String] string the raw output from the archive program's "list" command
      # @return [Array] a list of paths in the archive
      def archive_contents_string_to_array string
        string.split("\n")
      end
    end
  end
end

