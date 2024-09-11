# frozen_string_literal: true

require 'pg'
require_relative 'sql/sql_adapter'

# PostgresAdapter provides methods to interact with a PostgreSQL database.
# It connects to the database using provided connection parameters and
# can retrieve schema information and execute queries.
class PostgresqlAdapter < SQLAdapter
  def initialize(data_source) # rubocop:disable Lint/MissingSuper
    connection_params = {
      dbname: data_source.database,
      user: data_source.username,
      password: data_source.decrypt_password,
      host: data_source.host,
      port: data_source.port
    }
    @connection = PG.connect(connection_params)
  end

  def schemas
    columns_query = <<-SQL
    SELECT
      c.table_name,
      c.column_name,
      c.data_type,
      kcu.constraint_name,
      kcu.ordinal_position,
      kcu.position_in_unique_constraint,
      tc.constraint_type,
      ct.referenced_table_name,
      ct.referenced_column_name
    FROM information_schema.columns c
    LEFT JOIN information_schema.key_column_usage kcu
      ON c.table_name = kcu.table_name
      AND c.column_name = kcu.column_name
      AND c.table_schema = kcu.table_schema
    LEFT JOIN information_schema.table_constraints tc
      ON kcu.constraint_name = tc.constraint_name
      AND kcu.table_schema = tc.table_schema
    LEFT JOIN (
      SELECT
        r.conname AS constraint_name,
        ccu.table_name AS table_name,
        r.confrelid::regclass::text AS referenced_table_name,
        a.attname AS referenced_column_name,
        ccu.table_schema
      FROM pg_constraint r
      JOIN information_schema.constraint_column_usage ccu
        ON r.conname = ccu.constraint_name
        AND r.connamespace::regnamespace::text = ccu.constraint_schema
      JOIN pg_attribute a
        ON a.attnum = ANY (r.confkey)
        AND a.attrelid = r.confrelid
      WHERE r.contype = 'f'
    ) ct
      ON kcu.constraint_name = ct.constraint_name
      AND kcu.table_schema = ct.table_schema
      AND kcu.table_name = ct.table_name
    WHERE c.table_schema = 'public'
    SQL

    result = @connection.exec(columns_query)

    schemas = {}
    result.each do |row|
      table_name = row['table_name']
      schemas[table_name] ||= []
      column = {
        column_name: row['column_name'],
        data_type: row['data_type'],
        constraint_name: row['constraint_name'],
        ordinal_position: row['ordinal_position'],
        position_in_unique_constraint: row['position_in_unique_constraint'],
        constraint_type: row['constraint_type'],
        referenced_table_name: row['referenced_table_name'],
        referenced_column_name: row['referenced_column_name']
      }
      schemas[table_name] << column
    end
    schemas
  end

  def run_query(query, limit = 10, offset = 0, sort = nil)
    wrapped_query = "(#{query})"
    wrapped_query = add_sorting(wrapped_query, sort)
    wrapped_query = add_offset(wrapped_query, limit, offset)

    result = @connection.exec(wrapped_query)
    fields = result.fields
    values = result.values
    [fields] + values
  end

  def run_raw_query(query)
    result = @connection.exec(query)

    command = query.strip.split.first.upcase

    case command
    when 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER'
      result.cmd_tuples
    else
      result.values
    end
  end

  def table_structure_query(table_name)
    "select column_name, is_nullable, data_type, column_default, character_maximum_length, numeric_precision, numeric_scale, datetime_precision, udt_name, column_default, is_identity, identity_generation, identity_start, identity_increment, identity_maximum, identity_minimum, identity_cycle from information_schema.columns where table_name = '#{table_name}'"
  end
end
