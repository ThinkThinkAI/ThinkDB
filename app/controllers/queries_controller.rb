class QueriesController < ApplicationController
  before_action :set_query, only: %i[show edit update destroy]
  before_action :set_active_data_source, only: %i[index show metadata data]
  before_action :check_active_data_source, only: %i[index show metadata data]

  def index; end

  def show; end

  def new
    @query = Query.new
  end

  def edit; end

  def create
    @query = Query.new(query_params)

    respond_to do |format|
      if @query.save
        format.html { redirect_to query_url(@query), notice: 'Query was successfully created.' }
        format.json { render :show, status: :created, location: @query }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to query_url(@query), notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @query.destroy!

    respond_to do |format|
      format.html { redirect_to queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
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
    result_data = {}

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
    @query = Query.find(params[:id])
  end

  def query_params
    result = params.permit(:id, :sql, :name, :data_source_id, :column, :order)
    result[:data_source_id] ||= current_user.connected_data_source.id
    result
  end

  def set_active_data_source
    @active_data_source = current_user.connected_data_source
  end

  def check_active_data_source
    return unless @active_data_source.nil?

    redirect_to data_sources_path, notice: 'Please connect a data source first.' and return
  end
end
