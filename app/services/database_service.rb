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
end
