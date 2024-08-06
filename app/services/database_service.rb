# frozen_string_literal: true

# DatabaseService is responsible for creating the appropriate database adapter
# based on the provided data source configuration.
class DatabaseService
  ADAPTERS_DIR = File.expand_path('adapters', __dir__)
  ADAPTER_CLASSES = {}

  Dir[File.join(ADAPTERS_DIR, '*.rb')].each do |file|
    require_relative file
    adapter_name = File.basename(file, '.rb')
    config_name = adapter_name.split('_').first
    class_name = adapter_name.split('_').collect(&:capitalize).join
    ADAPTER_CLASSES[config_name] = Object.const_get(class_name)
  end

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
      puts key
      next if key == "Friendly"

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

  def all_records_query(table_name)
    @adapter.all_records_query(table_name)
  end

  def table_structure_query(table_name)
    @adapter.table_structure_query(table_name)
  end
end
