# frozen_string_literal: true

# Controller to manage DataSource objects for users. Allows creating, updating,
# and deleting DataSource records associated with the current user.
class DataSourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source, only: %i[edit update destroy connect]

  def index
    @data_sources = current_user.data_sources
  end

  def show
    redirect_to data_sources_path
  end

  def new
    @data_source = current_user.data_sources.build
  end

  def create
    @data_source = current_user.data_sources.build(data_source_params)

    if @data_source.save
      redirect_to '/query', notice: 'DataSource was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @data_source
  end

  def update
    if @data_source.update(data_source_params)
      redirect_to '/query', notice: 'DataSource was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @data_source.destroy

    respond_to do |format|
      if current_user.data_sources.exists?
        format.html { redirect_to '/query', notice: 'DataSource was successfully deleted.' }
      else
        format.html { redirect_to new_data_source_path, notice: 'No DataSource left. Please create a new one.' }
      end
    end
  end

  def connect
    updated_status = !@data_source.connected
    
    @data_source.update!(connected: updated_status)

    @data_source.reload

    message = 'DataSource connection status was successfully updated.'

    respond_to do |format|
      format.html { redirect_to '/query', notice: message }
      format.json { render json: { data_source: @data_source, message: }, status: :ok }
    end
  rescue StandardError => e
    respond_to do |format|
      format.html { redirect_to data_sources_path, alert: "Failed to update DataSource connection: #{e.message}" }
      format.json do
        render json: { message: e.message }, status: :unprocessable_entity
      end
    end
  end

  private

  def set_data_source
    @data_source = current_user.data_sources.friendly.find(params[:id])
  end

  def data_source_params
    params.require(:data_source).permit(:name, :adapter, :host, :port, :database, :username, :password, :connected)
  end
end
