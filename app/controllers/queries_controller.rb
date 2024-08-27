# frozen_string_literal: true

require 'ostruct'

class QueriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_query, only: %i[show edit update destroy]
  before_action :set_active_data_source, only: %i[index show metadata data]
  before_action :check_active_data_source, only: %i[index show metadata data]
  before_action :handle_sql, only: %i[index show]

  def index
    render :index
  end

  def show
    render :index
  end

  def new
    @query = Query.new
  end

  def edit; end

  def create
    @query = Query.new(query_params)

    respond_to do |format|
      if @query.save
        format.html do
          redirect_to data_source_query_path(@query.data_source, @query), notice: 'Query was successfully created.'
        end
        format.json { render :show, status: :created, location: data_source_query_path(@query.data_source, @query) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    return render json: { message: 'Query was not updated' }, status: :unprocessable_entity if params[:sql].blank?

    @query.update(sql: params[:sql])
    render json: { message: 'Query was updated.' }, status: :ok
  end

  def destroy
    @query.destroy!

    render json: { message: 'Query was successfully destroyed' }, status: :ok
  end

  def metadata
    return unless params[:sql].present? || @query.present?

    database_service = DatabaseService.build(@active_data_source)
    result_data = {}

    begin
      sql = @query ? @query.sql : params[:sql]
      result_data[:total_records] = database_service.count(sql)

      result_data[:column_names] = database_service.column_names(sql)
    rescue StandardError => e
      return render json: { failure: e.message }
    end

    render json: result_data
  end

  def data
    return unless params[:sql].present? || @query.present?

    sort = nil

    sort = { column: params[:column], order: params[:order] } if params[:column] && params[:order]

    database_service = DatabaseService.build(@active_data_source)

    begin
      sql = @query ? @query.sql : params[:sql]
      page = params[:page] ? params[:page].to_i : 1
      results_per_page = params[:results_per_page].to_i || 10

      formatted_results = database_service.run_query(sql, results_per_page:, page:, format: 'json', sort:)
    rescue StandardError => e
      return render json: { failure: e.message }
    end

    render json: formatted_results
  end

  private

  def set_query
    @query = Query.friendly.find(params[:id])
  end

  def query_params
    result = params.permit(:id, :sql, :name, :data_source_id, :column, :order, :query)
    result[:data_source_id] ||= current_user&.connected_data_source&.id
    result
  end

  def set_active_data_source
    @active_data_source = current_user.connected_data_source
  end

  def check_active_data_source
    return unless @active_data_source.nil?

    redirect_to data_sources_path, notice: 'Please connect a data source first.' and return
  end

  def handle_sql
    @sql = @query ? @query.sql : params[:sql]

    return unless @sql.present?
    return unless @sql.sql_modification? || @sql.sql_statement_count > 1

    database_service = DatabaseService.build(@active_data_source)

    @row_results = []

    @sql.split(';').each do |sql_statement|
      row_result = { error: false, message: '', count: 0, sql: '' }
      begin
        row_result[:sql] = sql_statement.strip.gsub("\r", '')
        row_result[:count] = if sql_statement.sql_modification?
                               database_service.run_raw_query(sql_statement)
                             else
                               database_service.run_raw_query(sql_statement).count
                             end
      rescue StandardError => e
        row_result[:error] = true
        row_result[:message] = e.message
      end

      @row_results << OpenStruct.new(row_result)
    end
  end
end
