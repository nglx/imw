module IMW
  module Schemes
    module Local

      module Base

        def self.extended obj
          if obj.directory?
            obj.extend(LocalDirectory)
          else
            obj.extend(LocalFile)
          end
        end

        [:executable?, :executable_real?, :exist?, :file?, :directory?, :ftype, :owned?, :pipe?, :readable?, :readable_real?, :setgid?, :setuid?, :size, :size?, :socket?, :split, :stat, :sticky?, :writable?, :writable_real?, :zero?].each do |class_method|
          define_method class_method do
            File.send(class_method, path)
          end
        end
        alias_method :exists?, :exist?

        def path
          @path ||= File.expand_path(@encoded_uri ? Addressable::URI.decode(uri.to_s) : uri.to_s)
        end

        def is_local?
          true
        end

        def dir
          IMW.open(dirname)
        end

      end

      module LocalFile

        def is_file?
          true
        end

        def rm
          should_exist!("Cannot delete")
          FileUtils.rm path
          self
        end
        alias_method :rm!, :rm

        def io
          @io ||= open(path, mode)
        end

        def close
          io.close if @io
          super()
        end

        def read length=nil
          io.read(length)
        end

        def readline
          io.readline
        end

        def write text
          io.write text
        end

        def << text
          io.write text.to_s + "\n"
        end

        def load &block
          if block_given?
            io.each do |line|
              yield line
            end
          else
            read.split("\n")
          end
        end

        def map &block
          io.map(&block)
        end

        def emit data, options={}
          data.each do |element|  # works if data is an Array or a String
            io << (element.to_s)
          end
        end

        def snippet
          [].tap do |snip|
            (io.read(1024) || '').bytes.each do |byte|
              # CR            LF          SPACE            ~
              snip << byte.chr if byte == 13 || byte == 10 || byte >= 32 && byte <= 126
            end
          end.join
        end

        def num_lines
          wc[0]
        end

        def num_words
          wc[1]
        end

        def num_chars
          wc[2]
        end


        def external_summary
          super().merge({
              :size      => size,
              :num_lines => num_lines
            })
        end

        protected

        def wc
          @wc ||= begin
                    `wc #{path}`.chomp.strip.split.map(&:to_i)
                  rescue
                    [nil,nil,nil] # FIXME
                  end
        end

      end

      module LocalDirectory

        def is_directory?
          true
        end

        def rmdir
          FileUtils.rmdir path
          self
        end
        alias_method :rmdir!, :rmdir

        def rm_rf
          FileUtils.rm_rf path
          self
        end
        alias_method :rm_rf!, :rm_rf

        def [] selector='*'
          Dir[File.join(path, selector)]
        end

        def contains? obj
          obj = IMW.open(obj)
          return false unless obj.is_local?
          return true  if obj.path == path
          return false unless obj.path.starts_with?(path)
          return true  if self[obj.path[path.length..-1]].size > 0
          false
        end

        def contents
          self['*']
        end

        def all_contents
          self['**/*']
        end

        def resources
          contents.map { |path| IMW.open(path) }
        end

        def all_resources
          all_contents.map do |path|
            IMW.open(path) unless File.directory?(path)
          end.compact
        end

        def cd &block
          FileUtils.cd(path, &block)
        end

        def create
          FileUtils.mkdir_p(path) unless exist?
          self
        end

        def join *paths
          IMW.open(File.join(stripped_uri.to_s, *paths))
        end

        def subdir! *paths
          IMW.dir!(File.join(stripped_uri.to_s, *paths))
        end

        def walk(options={}, &block)
          require 'find'
          Find.find(path) do |path|
            if options[:only]
              next if options[:only] == :files && !File.file?(path)
              next if options[:only] == :directories && !File.directory?(path)
              next if options[:only] == :symlinks && !File.symlink?(path)
            end
            yield path
          end
        end

        def external_summary
          super().merge(
            {
              :size      => size,
              :num_files => contents.length,
            })
        end

      end
    end
  end
end



