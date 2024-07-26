class QueriesController < ApplicationController
  before_action :set_query, only: %i[show edit update destroy]
  before_action :set_active_data_source, only: %i[index show]
  before_action :check_active_data_source, only: %i[index show]
  before_action :execute_query, only: %i[index show]

  def index
    render_template
  end

  def show
    render_template
  end

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

  private

  def set_query
    @query = Query.find(params[:id])
  end

  def query_params
    result = params.permit(:id, :sql, :name, :data_source_id)
    result[:data_source_id] ||= current_user.connected_data_source.id
    result
  end

  def set_active_data_source
    @active_data_source = DataSource.active.take
  end

  def check_active_data_source
    return unless @active_data_source.nil?

    redirect_to data_sources_path, notice: 'Please connect a data source first.' and return
  end

  def execute_query
    return unless params[:sql].present? || @query.present?

    database_service = DatabaseService.build(@active_data_source)

    begin
      sql = @query ? @query.sql : params[:sql]
      @page = params[:page] ? params[:page].to_i : 1
      @total_records = database_service.count(sql)
      @page_count = (@total_records.to_f / 10).ceil
      @results = database_service.run_query(sql, results_per_page: 10, page: @page)
    rescue StandardError => e
      @page = nil
      @page_count = nil
      @total_records = nil
      @failure = e.message
    end
  end

  def render_template
    render 'index'
  end
end
