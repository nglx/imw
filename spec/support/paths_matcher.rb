require 'set'

module Spec
  module Matchers
    module IMW

      class PathsMatcher

        attr_accessor :given, :given_contents, :given_base, :to_match, :to_match_contents, :to_match_base

        def initialize given, options={}
          @given_base     = options[:given_base] || options[:relative_to]
          @to_match_base  = options[:to_match_base]
          @given          = given
          @given_contents = get_contents(given, given_base)
        end
        
        def matches? to_match
          @to_match          = to_match
          @to_match_contents = get_contents(to_match, to_match_base)
          to_match_contents == given_contents
        end

        def failure_message
          given_string    = given_contents.to_a.join("\n\t")
          to_match_string = to_match_contents.to_a.join("\n\t")          
          "expected contents to be identical.\n\ngiven #{given}:\n\t#{given_string}\n\nto match #{to_match}:\n\t#{to_match_string}"
        end

        def negative_failure_message
          "expected contents of #{given} and #{to_match} to be different"
        end

        protected
        def get_contents obj, base=nil
          if obj.is_a?(String) || obj.is_a?(Array)
            contents = [obj].flatten.map do |raw_path|
              path = File.expand_path(raw_path)
              if File.directory?(path)
                Dir[path + "/**/*"]
              else
                path
              end
            end.flatten
          else
            # obj is an IMW obj (archive or directory) so it has a
            # contents method
            contents = obj.contents
          end
          if base
            contents.map do |path|
              new_path = path[base.length + 1..-1]
              new_path = nil if !new_path.nil? && new_path.size == 0
              new_path
            end.compact.to_set
          else
            contents.to_set
          end
        end
      end
      
      def contain_paths_like given, options={}
        PathsMatcher.new(given, options)
      end
    end
  end
end
