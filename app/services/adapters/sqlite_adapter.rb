# frozen_string_literal: true

require 'sqlite3'
require 'json'
require_relative 'sql/sql_adapter'

# SqliteAdapter provides methods to interact with an SQLite database.
# It connects to the database using a file location and
# can retrieve schema information and execute queries.
class SqliteAdapter < SQLAdapter
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
      m.type = 'table'
      AND m.name NOT LIKE 'sqlite_%';
    SQL

    result = @connection.execute(query)

    result.each_with_object({}) do |row, acc|
      table_name, column_name, data_type = row
      acc[table_name] ||= []
      acc[table_name] << {
        column_name:,
        data_type:
      }
    end
  end

  def run_query(query, limit = 10, offset = 0, sort = nil)
    wrapped_query = add_sorting(query, sort)
    wrapped_query = add_offset(wrapped_query, limit, offset)

    @connection.execute2(wrapped_query)
  end

  def run_raw_query(query)
    @connection.execute(query)
  end

  def table_structure_query(table_name)
    "PRAGMA table_info(#{table_name})"
  end
end
