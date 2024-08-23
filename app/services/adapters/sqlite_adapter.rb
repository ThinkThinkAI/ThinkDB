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
    table_query = "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';"
    tables = @connection.execute(table_query).flatten

    schemas = {}

    tables.each do |table_name|
      columns_query = "PRAGMA table_info(#{table_name});"
      foreign_keys_query = "PRAGMA foreign_key_list(#{table_name});"

      columns_result = @connection.execute(columns_query)
      foreign_keys_result = @connection.execute(foreign_keys_query)

      foreign_keys = foreign_keys_result.each_with_object({}) do |fk, hash|
        hash[fk[3]] = { table: fk[2], from: fk[3], to: fk[4] }
      end

      column_details = columns_result.map do |column|
        column_info = {
          column_name: column[1],
          data_type: column[2],
          not_null: column[3] == 1,
          default_value: column[4],
          primary_key: column[5] == 1
        }

        if column_info[:primary_key]
          column_info[:constraint_type] = 'PRIMARY KEY'
        elsif foreign_key = foreign_keys[column[1]]
          column_info[:constraint_type] = 'FOREIGN KEY'
          column_info[:referenced_table_name] = foreign_key[:table]
          column_info[:referenced_column_name] = foreign_key[:to]
        end

        column_info
      end

      schemas[table_name] = column_details
    end

    schemas
  end

  def run_query(query, limit = 10, offset = 0, sort = nil)
    wrapped_query = add_sorting(query, sort)
    wrapped_query = add_offset(wrapped_query, limit, offset)

    @connection.execute2(wrapped_query)
  end

  def run_raw_query(query)
    result = @connection.execute(query)

    command = query.strip.split.first.upcase
    case command
    when 'INSERT', 'UPDATE', 'DELETE'
      @connection.changes
    when 'DROP', 'CREATE', 'ALTER'
      0
    else
      result
    end
  end

  def table_structure_query(table_name)
    "PRAGMA table_info(#{table_name})"
  end
end
