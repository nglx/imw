require 'dbi'

module IMW
  module Schemes

    # Encapsulates a connection to a relational database.
    #
    # Calling
    #
    #   IMW.open('sql://host:port/database_name')
    #
    # shold create a connection to a database at the given +port+ on
    # the given +host+ using the given +database_name+.
    module SQL

      # A base implementation of a connection to a relational
      # database.
      #
      # The Base#extended method will examine the +scheme+ of an
      # object extended with this module and choose a more specific
      # database adaptor module to extend with as well.
      module Base

        # When an IMW::Resource is extended use URI's scheme to choose
        # which other module inside IMW::Schemes::SQL to extend with.
        def self.extended obj
          case obj.scheme
          when 'mysql'      then obj.extend(IMW::Schemes::SQL::MySQL)
          when 'postgresql' then obj.extend(IMW::Schemes::SQL::PostgreSQL)
          else raise IMW::ArgumentError.new("Unknown database type: #{obj.scheme}")
          end
        end
        
        # For an SQL connection the database will be the same as the
        # path.
        #
        # @return [String]
        def database
          @database ||= path.tr('/','')
        end

        # Redefineeach method inappropriate for databases.
        [:dirname, :basename, :extname, :extension, :name].each do |method|
          define_method(method) do
            nil
          end
        end

        # The (cached) database connection for this resource.
        #
        # @return [DBI::DatabaseHandle]
        def connection
          @connection ||= DBI.connect("#{dbi_module}:#{database}:#{host}", user, password)
        end

        # Return the password associated with user's account on the
        # given database.
        #
        # @return [String]
        def password
          @password ||= resource_options[:password]
        end

        # Return an array of the table names in the current database.
        #
        # @return [Array<String>]
        def tables
          returning([]) do |table_names|
            execute("SHOW TABLES") do |row|
              table_names << row.first
            end
          end
        end

        # Execute the (joined) +query_string_parts+ using this
        # resource's cached connection.
        #
        # If passed a block, yield each row of the result set to the
        # block.
        #
        # @param [Array<String>] query_string_parts
        # @yield [DBI::Row]
        # @return [DBI::StatementHandle]
        def execute *query_string_parts, &block
          query = query_string_parts.join(' ')
          IMW.announce_if_verbose "Querying #{self}: #{query}"
          statement = connection.execute(query)
          block_given? ? statement.fetch(&block) : statement
        end
      end

      # Module for MySQL databases.
      module MySQL

        # Return the name of the DBI module used to connect to MySQL.
        #
        # @return [String]
        def dbi_module
          "DBI:Mysql"
        end
      end

      # Module for PostgreSQL databases.
      module PostgreSQL

        # Return the name of the DBI module used to connect to PostgreSQL.
        #
        # @return [String]
        def dbi_module
          "DBI:Pg"
        end
      end
      
    end
  end
end
  
