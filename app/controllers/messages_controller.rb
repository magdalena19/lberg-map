class MessagesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if simple_captcha_valid? || @current_user.signed_in?
      save_new
    else
      flash[:danger] = t('.invalid_captcha')
      render :new
    end
  end

  private

  def save_new
    if @message.save
      send_email_message
      flash[:success] = t('.message_successfully_sent')
      redirect_to contact_url
    else
      flash[:danger] = @message.errors.full_messages.to_sentence
      render :new
    end
  end

  def send_email_message
    MailerWorker.perform_async(message_id: @message.id, copy_to_sender: params[:copy_to_sender])
  end

  def message_params
    params.require(:message).permit(:sender_name, :sender_email, :subject, :text, :tag)
  end
end
