# frozen_string_literal: true

require 'mysql2'
require 'json'

# MysqlAdapter provides methods to interact with a MySQL database.
# It connects to the database using provided connection parameters and
# can retrieve schema information and execute queries.
class MysqlAdapter
  def initialize(data_source)
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
    result = @client.query('SELECT table_name, column_name, data_type FROM information_schema.columns')

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

  def run_query(query, limit = 10, offset = 0)
    paginated_query = "#{query} LIMIT #{limit} OFFSET #{offset}"
    result = @client.query(paginated_query)
    result.to_a
  end
end
