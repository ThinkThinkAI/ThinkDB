# frozen_string_literal: true

# # frozen_string_literal: true

# require 'rails_helper'

# RSpec.describe String do
#   let(:select_query) { "SELECT * FROM users" }
#   let(:insert_query) { "INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com')" }
#   let(:create_table_query) { "CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(255), email VARCHAR(255))" }
#   let(:multi_statement_query) { "SELECT * FROM users; INSERT INTO users (name, email) VALUES ('Jane Doe', 'jane@example.com')" }

#   describe '#parsed' do
#     it 'parses the SQL string into a SQL::Parser::ASTNode' do
#       expect(select_query.parsed).to be_a(SQL::Statement::Select)
#     end
#   end

#   describe '#sql_modification?' do
#     it 'returns true for DML statements' do
#       expect(insert_query.sql_modification?).to be(true)
#     end

#     it 'returns true for DDL statements' do
#       expect(create_table_query.sql_modification?).to be(true)
#     end

#     it 'returns false for select statements' do
#       expect(select_query.sql_modification?).to be(false)
#     end
#   end

#   describe '#sql_select?' do
#     it 'returns true for select statements' do
#       expect(select_query.sql_select?).to be(true)
#     end

#     it 'returns false for non-select statements' do
#       expect(insert_query.sql_select?).to be(false)
#     end
#   end

#   describe '#sql_ddl?' do
#     it 'returns true for DDL statements' do
#       expect(create_table_query.sql_ddl?).to be(true)
#     end

#     it 'returns false for non-DDL statements' do
#       expect(insert_query.sql_ddl?).to be(false)
#     end
#   end

#   describe '#sql_dml?' do
#     it 'returns true for DML statements' do
#       expect(insert_query.sql_dml?).to be(true)
#     end

#     it 'returns false for non-DML statements' do
#       expect(create_table_query.sql_dml?).to be(false)
#     end
#   end

#   describe '#sql_statement_count' do
#     it 'counts the number of SQL statements in a string' do
#       expect(multi_statement_query.sql_statement_count).to eq(2)
#     end

#     it 'returns 1 for a single statement' do
#       expect(select_query.sql_statement_count).to eq(1)
#     end
#   end
# end
