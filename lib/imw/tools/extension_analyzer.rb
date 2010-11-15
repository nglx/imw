module IMW
  module Tools

    # Mixin with some heuristic methods for identifying common
    # extensions and likely data formats for a collection of files.
    #
    # Requires the including class to define a method +resources+ which
    # returns an array of IMW::Resource objects.
    module ExtensionAnalyzer

      # Return the file counts of each extension.
      #
      # @return [Hash]
      def extension_counts
        @extension_counts ||= returning({}) do |counts|
          resources.each do |resource|
            next if resource.is_directory?
            counts[resource.extension] = 0 unless counts.has_key?(resource.extension)
            counts[resource.extension] += 1
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
          num_files = resources.reject(&:is_directory?).length.to_f
          extension_counts.each_pair do |extension, count|
            weighted[extension] = count.to_f / num_files
          end
        end
      end

      # Return the amount of data corresponding to each extension.
      #
      # @return [Hash]
      def extension_sizes
        @extension_sizes ||= returning({}) do |sizes|
          resources.each do |resource|
            next if resource.is_directory?
            sizes[resource.extension] = 0 unless sizes.has_key?(resource.extension)            
            sizes[resource.extension] += resource.size
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
      # Summarizer's resources.
      #
      # @return [String]
      def most_common_extension
        return most_common_extension_by_size if most_common_extension_by_size == most_common_extension_by_count # no contest
        count_fraction = normalized_extension_counts[most_common_extension_by_count]
        size_fraction  = normalized_extension_sizes[most_common_extension_by_size]
        return most_common_extension_by_count if count_fraction > 0.5 and size_fraction < 0.5 # FIXME arbitrary
        return most_common_extension_by_size  if count_fraction < 0.5 and size_fraction > 0.5
        most_common_extension_by_size # default to size
      end

      # Returns a guess as to the most common data format for this
      # Summarizer's resources.
      #
      # @return [String]
      def most_common_data_format
        extension = most_common_extension
        ['tar', 'tar.bz2', 'tar.gz', 'tgz', 'tbz2', 'zip', 'rar'].include?(extension) ? 'archive' : extension
      end
    end
  end
end

