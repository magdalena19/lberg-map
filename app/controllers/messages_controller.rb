class MessagesController < ApplicationController
  include Recaptcha::Verify

  before_action :set_map

  def new
    @message = @map.messages.new
  end

  def create
    @message = @map.messages.new(message_params)
    if verify_recaptcha(model: @message) && @message.save
      send_email_message
      flash[:success] = t('.message_successfully_sent')
      redirect_to contact_url
    else
      flash[:danger] = @message.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def send_email_message
    MailerWorker.perform_async(message_id: @message.id, copy_to_sender: params[:copy_to_sender])
  end

  def message_params
    params.require(:message).permit(:sender_name, :sender_email, :subject, :text, :tag)
  end
end
