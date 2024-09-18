# frozen_string_literal: true

# TestAdapter allows for easier testing.
class TestAdapter
  def initialize(data_source); end

  def schemas
    {}
  end

  def run_query(query, limit = 10, offset = 0, sort = nil); end

  def run_raw_query(query); end

  def table_structure_query(table_name)
    "PRAGMA table_info(#{table_name})"
  end

  def count(_query)
    0
  end

  def all_records_query(table_name)
    "SELECT * FROM #{table_name}"
  end
end
