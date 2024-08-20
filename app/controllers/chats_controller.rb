# app/controllers/chats_controller.rb
class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source
  before_action :set_chat, only: %i[show edit update destroy]

  def index
    @chat = @data_source.chats.order(created_at: :desc).first
    @chat = @data_source.chats.create(name: 'Chat') if @chat.blank?

    render :show
  end

  def show
    @chat = @data_source.chats.friendly.find(params[:id])
  end

  def new
    @chat = @data_source.chats.create(name: 'Chat')
    redirect_to '/chat'
  end

  def create
    @chat = @data_source.chats.new(chat_params)
    if @chat.save
      redirect_to data_source_chat_path(@data_source, @chat), notice: 'Chat was successfully created.'
    else
      puts @chat.errors.full_messages
      render :new
    end
  end

  def edit; end

  def update
    if @chat.update(chat_params)
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
    @data_source = DataSource.find(params[:data_source_id])
  end

  def set_chat
    @chat = @data_source.chats.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:name)
  end
end
