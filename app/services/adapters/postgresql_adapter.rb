# frozen_string_literal: true

require 'pg'
require_relative 'sql/sql_adapter'

# PostgresAdapter provides methods to interact with a PostgreSQL database.
# It connects to the database using provided connection parameters and
# can retrieve schema information and execute queries.
class PostgresqlAdapter < SQLAdapter
  def initialize(data_source)
    connection_params = {
      dbname: data_source.database,
      user: data_source.username,
      password: data_source.password,
      host: data_source.host,
      port: data_source.port
    }
    @connection = PG.connect(connection_params)
  end

  def schemas
    columns_query = <<-SQL
      SELECT c.table_name, c.column_name, c.data_type,
             k.constraint_name, k.ordinal_position, k.position_in_unique_constraint, k.referenced_table_name, k.referenced_column_name,
             t.constraint_type
      FROM information_schema.columns c
      LEFT JOIN information_schema.key_column_usage k
      ON c.table_schema = k.table_schema
      AND c.table_name = k.table_name
      AND c.column_name = k.column_name
      LEFT JOIN information_schema.table_constraints t
      ON k.constraint_name = t.constraint_name
      WHERE c.table_schema = 'public'
    SQL

    result = @connection.exec(columns_query)

    schemas = {}
    result.each do |row|
      table_name = row['table_name']
      schemas[table_name] ||= []
      column = {
        column_name: row['column_name'],
        data_type: row['data_type'],
        constraint_name: row['constraint_name'],
        ordinal_position: row['ordinal_position'],
        position_in_unique_constraint: row['position_in_unique_constraint'],
        referenced_table_name: row['referenced_table_name'],
        referenced_column_name: row['referenced_column_name'],
        constraint_type: row['constraint_type']
      }
      schemas[table_name] << column
    end
    schemas
  end

  def run_query(query, limit = 10, offset = 0, sort = nil)
    wrapped_query = add_sorting(query, sort)
    wrapped_query = add_offset(wrapped_query, limit, offset)

    result = @connection.exec(wrapped_query)
    fields = result.fields
    values = result.values
    [fields] + values
  end

  def run_raw_query(query)
    result = @connection.exec(query)

    command = query.strip.split.first.upcase

    case command
    when 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER'
      result.cmd_tuples
    else
      result.values
    end
  end

  def table_structure_query(table_name)
    "select * from information_schema.columns where table_name = '#{table_name}'"
  end
end
