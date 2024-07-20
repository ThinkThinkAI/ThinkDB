# frozen_string_literal: truegi

require 'pg'

# PostgresAdapter provides methods to interact with a PostgreSQL database.
# It connects to the database using provided connection parameters and
# can retrieve schema information and execute queries.
class PostgresAdapter
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

  def get_schemas
    result = @connection.exec('SELECT table_name, column_name, data_type FROM information_schema.columns')

    schemas = result.each_with_object({}) do |row, acc|
      table_name = row['table_name']
      acc[table_name] ||= []
      acc[table_name] << {
        column_name: row['column_name'],
        data_type: row['data_type']
      }
    end

    schemas.to_json
  end

  def run_query(query)
    result = @connection.exec(query)
    result.values
  end
end
