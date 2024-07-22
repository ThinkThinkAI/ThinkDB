# frozen_string_literal: true

require 'sqlite3'
require 'json'

# SqliteAdapter provides methods to interact with an SQLite database.
# It connects to the database using a file location and
# can retrieve schema information and execute queries.
class SqliteAdapter
  def initialize(data_source)
    @db_file = data_source.database
    @connection = SQLite3::Database.new(@db_file)
  end

  def schemas
    query = <<-SQL
      SELECT
        m.name AS table_name,
        p.name AS column_name,
        p.type AS data_type
      FROM
        sqlite_master m
        JOIN pragma_table_info(m.name) p
      WHERE
        m.type = 'table';
    SQL

    result = @connection.execute(query)

    schemas = result.each_with_object({}) do |row, acc|
      table_name, column_name, data_type = row
      acc[table_name] ||= []
      acc[table_name] << {
        column_name:,
        data_type:
      }
    end

    schemas.to_json
  end

  def run_query(query, limit = 10, offset = 0)
    paginated_query = "#{query} LIMIT #{limit} OFFSET #{offset}"
    @connection.execute(paginated_query)
  end

  def run_raw_query(query)
    @connection.execute(paginated_query)
  end
end
