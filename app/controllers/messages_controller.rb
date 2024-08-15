# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source
  before_action :set_chat
  before_action :set_message, only: :destroy

  def create
    @message = @chat.messages.new(message_params)
    if @message.save
      redirect_to data_source_chat_path(@data_source, @chat), notice: 'Message was successfully created.'
    else
      render 'chats/show'
    end
  end

  def destroy
    @message.destroy
    redirect_to data_source_chat_path(@data_source, @chat), notice: 'Message was successfully destroyed.'
  end

  private

  def set_data_source
    @data_source = DataSource.find(params[:data_source_id])
  end

  def set_chat
    @chat = @data_source.chats.friendly.find(params[:chat_id])
  end

  def set_message
    @message = @chat.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:role, :content)
  end
end
