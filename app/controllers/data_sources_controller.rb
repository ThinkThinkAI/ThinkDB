# frozen_string_literal: true

# app/controllers/data_sources_controller.rb

# Controller to manage DataSource objects for users. Allows creating, updating,
# and deleting DataSource records associated with the current user.
class DataSourcesController < ApplicationController
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

    respond_to do |format|
      if @data_source.save
        format.turbo_stream
        format.html { redirect_to data_sources_url, notice: 'DataSource was successfully created.' }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('new_tier',
                                                    partial: 'data_sources/form',
                                                    locals: { data_source: @data_source }),
                 status: :unprocessable_entity
        end

        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @data_source
  end

  def update
    if @data_source.update(data_source_params)
      redirect_to data_sources_path, notice: 'DataSource was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @data_source.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@data_source) }
      format.html { redirect_to data_sources_path, notice: 'Data source was successfully destroyed.' }
    end
  end

  def connect
    @data_source.update(connected: !@data_source.connected)
    redirect_to data_sources_path, notice: 'DataSource connection status was successfully updated.'
  end

  private

  def set_data_source
    @data_source = current_user.data_sources.find(params[:id])
  end

  def data_source_params
    params.require(:data_source).permit(:name, :adapter, :host, :port, :database, :username, :password, :connected)
  end
end
