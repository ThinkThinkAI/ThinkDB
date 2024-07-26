# frozen_string_literal: true

require 'pg'
require_relative 'sql_adapter'

# PostgresAdapter provides methods to interact with a PostgreSQL database.
# It connects to the database using provided connection parameters and
# can retrieve schema information and execute queries.
class PostgresAdapter < SQLAdapter
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
    result = @connection.exec("SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = 'public'")

    result.each_with_object({}) do |row, acc|
      table_name = row['table_name']
      acc[table_name] ||= []
      acc[table_name] << {
        column_name: row['column_name'],
        data_type: row['data_type']
      }
    end
  end

  def run_query(query, limit = 10, offset = 0)
    paginated_query = "#{query} LIMIT #{limit} OFFSET #{offset}"
    result = @connection.exec(paginated_query)
    fields = result.fields
    values = result.values
    [fields] + values
  end

  def run_raw_query(query)
    result = @connection.exec(query)
    result.values
  end
end
