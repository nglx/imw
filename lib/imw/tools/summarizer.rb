module IMW
  module Tools

    # A class for producing summary data about a collection of
    # resources.
    #
    # This summary data includes the directory tree, file sizes, file
    # formats, record counts, &c.
    class Summarizer

      # The inputs to this Summarizer.
      attr_reader :inputs

      # Initialize a new Summarizer with the given +inputs+.
      #
      # @param [Array<String, IMW::Resource>] inputs
      # @return [IMW::Tools::Summarizer]
      def initialize *inputs
        self.inputs = inputs.flatten
      end

      # Set new inputs for this summarizer.
      #
      # Clears any cached summary statistics
      #
      # @param [Array<String, IMW::Resource>] new_inputs
      def inputs= new_inputs
        @inputs = new_inputs.map do |input|
          i = IMW.open(input)
          raise PathError.new("Invalid input, #{i.path}") if i.is_local? && !i.exist? # don't check for remote files
          i.is_directory? ? i.resources : i
        end.compact.flatten
        clear_cached_statistics!
      end

      # Reset all the cached statistics of this summarizer to +nil+.
      def clear_cached_statistics!
        [:num_files,
         :num_direcories,
         :total_size,
         :extension_counts,
         :most_common_extension_by_count,
         :normalized_extension_counts,
         :extension_sizes,
         :most_common_extension_by_size,
         :normalized_extension_sizes].each do |instance_variable|
          self.instance_variable_set("@#{instance_variable}", nil)
        end
      end

      # Return the number of files.
      #
      # @return [Integer]
      def num_files
        @num_files ||= inputs.size
      end

      # Return the number of directories.
      #
      # @return [Integer]
      def num_directories
        @num_directories ||= inputs.collect { |input| input.is_directory? }
      end

      # Return the total size.
      #
      # @return [Integer]
      def total_size
        @total_size ||= inputs.map(&:size).inject(0) { |e, sum| sum += e }
      end

      # Return the file counts of each extension.
      #
      # @return [Hash]
      def extension_counts
        @extension_counts ||= returning({}) do |counts|
          inputs.each do |input|
            next if input.is_directory?
            counts[input.extension] = 0 unless counts.has_key?(input.extension)
            counts[input.extension] += 1
          end
        end
      end

      # Return the most common extension by count of files.
      def most_common_extension_by_count
        return @most_common_extension_by_count if @most_common_extension_by_count
        current_count, current_extension = 0, nil
        extension_counts.each_pair do |extension, count|
          current_extension = extension if count > current_count
        end
        if current_extension.strip.blank? then current_extension = 'flat' end
        @most_common_extension_by_count = current_extension
      end

      # Return the file counts of each extension, normalized by the
      # total number of files.
      #
      # @return [Hash]
      def normalized_extension_counts
        @normalized_extension_counts ||= returning({}) do |weighted|
          extension_counts.each_pair do |extension, count|
            weighted[extension] = count.to_f / num_files.to_f
          end
        end
      end

      # Return the amount of data corresponding to each extension.
      #
      # @return [Hash]
      def extension_sizes
        @extension_sizes ||= returning({}) do |sizes|
          inputs.each do |input|
            next if input.is_directory?
            sizes[input.extension] = 0 unless sizes.has_key?(input.extension)            
            sizes[input.extension] += input.size
          end
        end
      end

      # Return the most common extension by amount of data.
      #
      # @return [String]
      def most_common_extension_by_size
        return @most_common_extension_by_size if @most_common_extension_by_size
        current_size, current_extension = 0, nil
        extension_sizes.each_pair do |extension, size|
          current_extension = extension if size > current_size
        end
        if current_extension.strip.blank? then current_extension = 'flat' end
        @most_common_extension_by_size = current_extension
      end

      # Return the fractional share of each extension by file size.
      #
      # @return [Hash]
      def normalized_extension_sizes
        @normalized_extension_sizes ||= returning({}) do |weighted|
          extension_sizes.each_pair do |extension, size|
            weighted[extension] = size.to_f / total_size.to_f
          end
        end
      end

      # Return a guess as to the most common extension format for this
      # Summarizer's inputs.
      #
      # @return [String]
      def most_common_extension
        return most_common_extension_by_size if most_common_extension_by_size == most_common_extension_by_count # no contest
        count_fraction = normalized_extension_counts[most_common_extension_by_count]
        size_fraction  = normalized_extension_sizes[most_common_extension_by_size]
        return most_common_extension_by_count if count_fraction > 0.5 and size_fraction < 0.5 # choose the winner based on differential
        return most_common_extension_by_size  if count_fraction < 0.5 and size_fraction > 0.5
        most_common_extension_by_size # default to size
      end

      # Returns a guess as to the most common data format for this
      # Summarizer's inputs.
      #
      # @return [String]
      def most_common_data_format
        extension = most_common_extension
        ['tar', 'tar.bz2', 'tar.gz', 'tgz', 'tbz2', 'zip', 'rar'].include?(extension) ? 'archive' : extension
      end
      
    end
  end
end
