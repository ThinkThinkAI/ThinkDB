# app/services/database_service.rb
require_relative 'adapters/postgres_adapter'
require_relative 'adapters/mysql_adapter'
require_relative 'adapters/sqlite_adapter'

# DatabaseService is responsible for creating the appropriate database adapter
# based on the provided data source configuration.
class DatabaseService
  ADAPTER_CLASSES = {
    'postgresql' => PostgresAdapter,
    'mysql' => MysqlAdapter,
    'sqlite' => SqliteAdapter
  }.freeze

  def self.build(data_source)
    adapter_class = ADAPTER_CLASSES[data_source.adapter]
    raise "Adapter not supported: #{data_source.adapter}" unless adapter_class

    new(adapter_class.new(data_source))
  end

  def initialize(adapter)
    @adapter = adapter
  end

  def schemas
    @adapter.schemas
  end

  def run_query(query, results_per_page: 10, page: 1)
    offset = (page - 1) * results_per_page
    @adapter.run_query(query, results_per_page, offset)
  end

  def run_raw_query(query)
    @adapter.run_raw_query(query)
  end

  def count(query)
    return nil unless supported_query_type?(query)

    count_query = convert_to_count_query(query)
    result = run_raw_query(count_query)
    result.first['count'].to_i
  end

  private

  def supported_query_type?(query)
    query.strip.downcase.start_with?('select', 'update', 'delete', 'insert')
  end

  def convert_to_count_query(query)
    case query.strip.split(/\s+/).first.downcase
    when 'select'
      "SELECT COUNT(*) AS count FROM (#{query}) AS subquery"
    when 'update', 'delete'
      table_name = extract_table_name(query)
      where_clause = extract_where_clause(query)
      "SELECT COUNT(*) AS count FROM #{table_name} #{where_clause}"
    when 'insert'
      extract_insert_count_query(query)
    end
  end

  def extract_table_name(query)
    match = query.match(/(?:update|delete\s+from|insert\s+into)\s+(\w+)/i)
    match ? match[1] : nil
  end

  def extract_where_clause(query)
    match = query.match(/where\s+(.*)/i)
    match ? "WHERE #{match[1]}" : ''
  end

  def extract_insert_count_query(query)
    if query.strip.downcase.include?('select')
      select_query = query.sub(/insert\s+into.*select/i, 'SELECT')
      "SELECT COUNT(*) AS count FROM (#{select_query}) AS subquery"
    else
      values_clause = query.match(/values\s*\((.*)\)/i)[1]
      row_count = values_clause.split('),').size
      "SELECT #{row_count} AS count"
    end
  end
end
