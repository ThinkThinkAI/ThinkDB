# config/initializers/string_extensions.rb

# Adds some sql methods to the String class.
class String
  def sql_modification?
    !!match(/\A\s*(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER)\b/i)
  end

  def sql_select?
    !!match(/\A\s*(SELECT)\b/i)
  end

  def sql_ddl?
    !!match(/\A\s*(CREATE|ALTER|DROP)\b/i)
  end

  def sql_dml?
    !!match(/\A\s*(INSERT|UPDATE|DELETE|SELECT)\b/i)
  end

  def sql_statement_count
    split(/\s*;\s*/).size
  end
end
