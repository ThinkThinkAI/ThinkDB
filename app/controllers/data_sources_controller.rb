# frozen_string_literal: true

# Controller to manage DataSource objects for users. Allows creating, updating,
# and deleting DataSource records associated with the current user.
class DataSourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source, only: %i[show edit update destroy connect]

  def show; end

  def new
    @data_source = current_user.data_sources.build
  end

  def create
    @data_source = current_user.data_sources.build(data_source_params)

    if DatabaseService.test_connection(@data_source)
      if @data_source.save
        redirect_to '/query', notice: 'DataSource was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = 'Failed to connect to the DataSource. Please check your configuration.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @data_source
  end

  def update
    @data_source.assign_attributes(data_source_params)

    if DatabaseService.test_connection(@data_source)
      if @data_source.save
        redirect_to '/query', notice: 'DataSource was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash[:alert] = 'Failed to connect to the DataSource. Please check your configuration.'
      render :edit, status: :unprocessable_entity
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
    @data_source.assign_attributes(connected: !@data_source.connected)

    if DatabaseService.test_connection(@data_source)
      @data_source.save
      message = 'DataSource connection status was successfully updated.'

      respond_to do |format|
        format.html { redirect_to '/query' }
        format.json { render json: { data_source: @data_source, message: }, status: :ok }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to determine_redirect_path,
                      alert: 'Failed to connect to the DataSource. Please check your configuration.'
        end
        format.json do
          render json: { message: 'Failed to update DataSource connection: Invalid configuration.' },
                 status: :unprocessable_entity
        end
      end
    end
  rescue StandardError => e
    respond_to do |format|
      format.html do
        redirect_to determine_redirect_path,
                    alert: "Failed to update DataSource connection: #{e.message}"
      end
      format.json { render json: { message: e.message }, status: :unprocessable_entity }
    end
  end

  private

  def determine_redirect_path
    return edit_data_source_path(@data_source) if @data_source

    request.referer || root_path
  end

  def set_data_source
    @data_source = current_user.data_sources.friendly.find(params[:id])
  end

  def data_source_params
    params.require(:data_source).permit(:name, :adapter, :host, :port, :database, :username, :password, :connected)
  end
end
