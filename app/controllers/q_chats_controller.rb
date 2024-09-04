# frozen_string_literal: true

# QChatsController manages the CRUD operations for QChat resources.
# It ensures that user authentication is required and sets up the
# appropriate data source before performing actions.
class QChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source
  before_action :set_qchat, only: %i[show edit update destroy]

  def index
    @chat = @data_source.qchats.order(created_at: :desc).first
    @chat = @data_source.qchats.create(name: 'Chat') if @chat.blank?

    render :show
  end

  def show
    @chat = @data_source.qchats.friendly.find(params[:id])
  end

  def new
    @chat = @data_source.qchats.create(name: 'Chat')
    redirect_to '/qchat'
  end

  def create
    @chat = @data_source.qchats.new(qchat_params)
    if @chat.save
      redirect_to data_source_chat_path(@data_source, @chat), notice: 'Chat was successfully created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @chat.update(qchat_params)
      redirect_to data_source_chat_path(@data_source, @chat), notice: 'Chat was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @chat.destroy
    respond_to do |format|
      format.html { redirect_to data_source_chats_path(@data_source), notice: 'Chat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_data_source
    @data_source = DataSource.friendly.find(params[:data_source_id] || current_user.connected_data_source.id)
  end

  def set_qchat
    @chat = @data_source.qchats.friendly.find(params[:id])
  end

  def qchat_params
    params.permit(:name)
  end
end
