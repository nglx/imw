module IMW
  module Formats

    # Defines methods for reading and writing Microsoft Excel data.
    module Excel

      # Ensure that this Excel resource is described by a an ordered
      # collection of flat fields.
      def validate_schema!
        raise IMW::SchemaError.new("#{self.class} resources must be described by an ordered set of flat fields") if schema.any?(&:nested?)
      end

      # Return the data in this Excel document as an array of arrays.
      #
      # Data from consecutive worksheets will be concatenated into a
      # single outer array.
      #
      # @return [Array<Array>]
      def load
        require 'spreadsheet'
        data = []
        Spreadsheet.open(path).worksheets.each do |worksheet|
          data += worksheet.map do |row|
            row.to_a
          end
        end
        data
      end

      # Gives us goodies!  Needs +each+ below.
      include Enumerable      

      # Yield each row of this Excel document.
      #
      # Will loop from one worksheet to the next.
      #
      # @yield [Spreadsheet::Excel::Row]
      def each &block
        require 'spreadsheet'
        Spreadsheet.open(path).worksheets.each do |worksheet|
          worksheet.each(&block)
        end
      end

      # Return the number of lines in this Excel document.
      #
      # Measured across worksheets.
      #
      # @return [Integer]
      def num_lines
        require 'spreadsheet'
        Spreadsheet.open(path).worksheets.inject(0) do |sum, worksheet|
          sum += worksheet.row_count
        end
      end

      # TODO
      # 
      # def emit
      # end

      # TODO
      #
      # Extract the following methods from delimited into a module and
      # let both Excel and Delimited use them.
      #
      # Or let Excel include Delimited and let it override
      # appropriately.
      # 
      #   headers_in_first_line?
      #   guess_schema!
      #
      #

      # 
      def snippet
        require 'spreadsheet'
        returning([]) do |snip|
          row_num = 1
          Spreadsheet.open(path).worksheets.each do |worksheet|
            worksheet.each do |row|
              break if row_num > 10
              snip << row.to_a
              row_num += 1
            end
            break if row_num > 10
          end
        end
      end
    end
  end
end
  
