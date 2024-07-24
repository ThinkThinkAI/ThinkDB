class QueriesController < ApplicationController
  before_action :set_query, only: %i[show edit update destroy]

  def index
    active_data_source = DataSource.active.take

    return redirect_to data_sources_path, notice: 'Please connect a data source first.' if active_data_source.nil?

    return unless params[:sql].present?

    database_service = DatabaseService.build(active_data_source)

    begin
      @query = params[:sql]
      @page = params[:page] ? params[:page].to_i : 1
      @total_records = database_service.count(@query)
      puts @total_records
      @page_count = (@total_records.to_f / 10).ceil
      @results = database_service.run_query(@query, results_per_page: 10, page: @page)
    rescue StandardError => e
      @page = nil
      @page_count = nil
      @total_records = nil
      @failure = e.message
    end
  end

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

  private

  def set_query
    @query = Query.find(params[:id])
  end

  def query_params
    params.require(:query).permit(:query, :data_source_id)
  end
end
