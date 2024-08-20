# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_source
  before_action :set_chat
  before_action :set_message, only: :destroy

  def create
    @chat = Chat.friendly.find(params[:chat_id])
    @message = @chat.messages.new(message_params)

    if @message.save
      AIResponseJob.perform_async(@chat.id)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to data_source_chat_path(@data_source, @chat), notice: "Message sent!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message", partial: "form", locals: { chat: @chat, data_source: @data_source, message: @message.errors }) }
        format.html { redirect_to data_source_chat_path(@data_source, @chat), alert: "Message could not be sent!" }
      end
    end
  end

  def destroy
    @message.destroy
    redirect_to data_source_chat_path(@data_source, @chat), notice: 'Message was successfully destroyed.'
  end

  private

  def set_data_source
    @data_source = current_user.connected_data_source
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
