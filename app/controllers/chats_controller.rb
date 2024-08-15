# app/controllers/chats_controller.rb
class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source

  def index
    @chat = @data_source.chats.order(created_at: :desc).first
    @chat = @data_source.chats.create(name: "New Chat") if @chat.blank?

    render :show
  end

  def show
    @chat = @data_source.chats.friendly.find(params[:id])
  end

  def new
    @chat = @data_source.chats.new
  end

  def create
    @chat = @data_source.chats.new(chat_params)
    if @chat.save
      redirect_to data_source_chat_path(@data_source, @chat), notice: 'Chat was successfully created.'
    else
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
    redirect_to data_source_chats_path(@data_source), notice: 'Chat was successfully destroyed.'
  end

  private

  def set_data_source
    @data_source = current_user.connected_data_source
  end

  def chat_params
    params.require(:chat).permit(:name)
  end
end
