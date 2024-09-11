# frozen_string_literal: true

# config/initializers/string_extensions.rb

# Adds some sql methods to the String class.
class String
  def sql_modification?
    sql_dml? || sql_ddl? || sql_pragma_assignment?
  end

  def sql_select?
    !!match(/\A\s*(SELECT)\b/i)
  end

  def sql_ddl?
    !!match(/\A\s*(CREATE|ALTER|DROP|SET)\b/i)
  end

  def sql_dml?
    !!match(/\A\s*(INSERT|UPDATE|DELETE)\b/i)
  end

  def sql_pragma_assignment?
    !!match(/\A\s*PRAGMA\s+\w+\s*=\s*\S+/i)
  end

  def sql_statement_count
    split(/\s*;\s*/).size
  end
end
