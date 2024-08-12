# frozen_string_literal: true

# The TablesController handles requests related to the Table model.
# It is responsible for retrieving and displaying individual tables
# that belong to a specific DataSource.
class TablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source
  before_action :set_database_service
  before_action :set_table, only: [:show]

  def show
    @all_records_query = @database_service.all_records_query(@table.name)
    @table_structure_query = @database_service.table_structure_query(@table.name)
  end

  private

  def set_data_source
    @data_source = DataSource.friendly.find(params[:data_source_id])
  end

  def set_database_service
    @database_service = DatabaseService.build(@data_source)
  end

  def set_table
    @table = @data_source.tables.friendly.find(params[:id])
  end
end
