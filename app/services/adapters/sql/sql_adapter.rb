# frozen_string_literal: true

# Adapter class to interact with SQL databases.
# Provides methods for executing queries and counting records.
class SQLAdapter
  def count(query)
    return nil unless supported_query_type?(query)

    limit = extract_limit(query)
    return limit if limit

    count_query = convert_to_count_query(query)

    result = run_raw_query(count_query)
    result.first[0]
  end

  def run_raw_query(query)
    raise NotImplementedError, 'Subclasses must implement the run_raw_query method'
  end

  def all_records_query(table_name)
    "SELECT * FROM #{table_name}"
  end

  private

  def select_query?(query)
    query.strip.match?(/^\(?SELECT/i)
  end

  def add_offset(query, limit, offset)
    return query unless select_query?(query)

    "#{query} LIMIT #{limit} OFFSET #{offset}"
  end

  def add_sorting(query, sort)
    return query unless select_query?(query)
    return query unless sort && sort[:column]

    "#{query} ORDER BY #{sort[:column]} #{sort[:order].upcase}"
  end

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

  def extract_limit(query)
    match = query.match(/LIMIT\s+(\d+)/i)
    match ? match[1].to_i : nil
  end
end
