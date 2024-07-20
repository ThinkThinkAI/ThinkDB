# app/services/database_service.rb
require_relative 'adapters/postgres_adapter'
class DatabaseService
  def self.build(data_source)
    adapter = case data_source.adapter
              when 'postgresql'
                PostgresAdapter.new(data_source)
              else
                raise "Adapter not supported: #{data_source.adapter}"
              end
    new(adapter)
  end

  def initialize(adapter)
    @adapter = adapter
  end

  def get_schemas
    @adapter.get_schemas
  end

  def run_query(query)
    @adapter.run_query(query)
  end
end
