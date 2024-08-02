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

    new(adapter_class.new(data_source), data_source)
  end

  def initialize(adapter, data_source)
    @adapter = adapter
    @data_source = data_source
  end

  def build_tables
    schemas = @adapter.schemas

    @data_source.update(schema: schemas.to_json)
    @data_source.tables.destroy_all

    schemas.each_key do |key|
      @data_source.tables.create(name: key)
    end
  end

  def format_json(data)
    if data.any?
      headers = data.shift
      data.map do |row|
        headers.zip(row).to_h
      end
    else
      []
    end
  end

  def run_query(query, results_per_page: 10, page: 1, format: 'default', sort: nil)
    offset = (page - 1) * results_per_page

    raw_data = @adapter.run_query(query, results_per_page, offset, sort)

    case format
    when 'json'
      format_json(raw_data)
    else
      raw_data
    end
  end

  def run_raw_query(query)
    @adapter.run_raw_query(query)
  end

  def column_names(query)
    run_query(query, results_per_page: 1).first
  end

  def count(query)
    @adapter.count(query)
  end
end
