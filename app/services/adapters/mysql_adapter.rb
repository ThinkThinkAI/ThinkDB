# frozen_string_literal: true

require 'mysql2'
require 'json'
require_relative 'sql/sql_adapter'

# MysqlAdapter provides methods to interact with a MySQL database.
# It connects to the database using provided connection parameters and
# can retrieve schema information and execute queries.
class MysqlAdapter < SQLAdapter
  def initialize(data_source)
    @data_source = data_source
    connection_params = {
      database: data_source.database,
      username: data_source.username,
      password: data_source.password,
      host: data_source.host,
      port: data_source.port
    }
    @client = Mysql2::Client.new(connection_params)
  end

  def schemas
    qry = "SELECT table_name, column_name, data_type FROM information_schema.columns where table_schema='#{@data_source.username}'"

    result = run_raw_query(qry)

    result.each_with_object({}) do |row, acc|
      table_name = row[0]
      acc[table_name] ||= []
      acc[table_name] << {
        column_name: row[1],
        data_type: row[2]
      }
    end
  end

  def run_query(query, limit = 10, offset = 0, sort = nil)
    wrapped_query = add_sorting(query, sort)
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
