# frozen_string_literal: true

# Adapter class to interact with SQL databases.
# Provides methods for executing queries and counting records.
class SQLAdapter
  def count(query)
    return nil unless supported_query_type?(query)

    count_query = convert_to_count_query(query)
    puts count_query.inspect
    result = run_raw_query(count_query)
    puts result.inspect
    result.first[0]
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
