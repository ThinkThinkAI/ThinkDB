# frozen_string_literal: true

require 'mysql2'
require 'json'
require_relative 'sql/sql_adapter'

# MysqlAdapter provides methods to interact with a MySQL database.
# It connects to the database using provided connection parameters and
# can retrieve schema information and execute queries.
class MysqlAdapter < SQLAdapter
  def initialize(data_source) # rubocop:disable Lint/MissingSuper
    @data_source = data_source
    connection_params = {
      database: data_source.database,
      username: data_source.username,
      password: data_source.decrypt_password,
      host: data_source.host,
      port: data_source.port
    }
    @client = Mysql2::Client.new(connection_params)
  end

  def schemas
    columns_query = <<-SQL
      SELECT DISTINCT c.table_name, c.column_name, c.data_type,
             k.constraint_name, k.ordinal_position, k.position_in_unique_constraint, k.referenced_table_name, k.referenced_column_name,
             t.constraint_type
      FROM information_schema.columns c
      LEFT JOIN information_schema.key_column_usage k
      ON c.table_schema = k.table_schema
      AND c.table_name = k.table_name
      AND c.column_name = k.column_name
      LEFT JOIN information_schema.table_constraints t
      ON k.constraint_name = t.constraint_name
      WHERE c.table_schema = '#{@data_source.database}'
    SQL

    result = run_raw_query(columns_query)

    result.each_with_object({}) do |row, acc|
      table_name = row[0]
      acc[table_name] ||= []
      column = {
        column_name: row[1],
        data_type: row[2],
        constraint_name: row[3],
        ordinal_position: row[4],
        position_in_unique_constraint: row[5],
        referenced_table_name: row[6],
        referenced_column_name: row[7],
        constraint_type: row[8]
      }
      acc[table_name] << column
    end
  end

  def run_query(query, limit = 10, offset = 0, sort = nil)
    wrapped_query = "(#{query})"
    wrapped_query = add_sorting(wrapped_query, sort)
    wrapped_query = add_offset(wrapped_query, limit, offset)

    result = @client.query(wrapped_query)

    keys = result.first.keys
    transformed_result = result.map(&:values)
    transformed_result.unshift(keys)

    transformed_result
  end

  def run_raw_query(query)
    result = @client.query(query)

    command = query.strip.split.first.upcase

    case command
    when 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER'
      result.affected_rows
    else
      result.map(&:values)
    end
  end

  def table_structure_query(table_name)
    "SHOW COLUMNS FROM #{table_name}"
  end
end
