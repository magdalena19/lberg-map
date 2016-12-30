class MessagesController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if simple_captcha_valid? || signed_in?
      save_new
    else
      flash[:danger] = t('.invalid_captcha')
      render :new
    end
  end

  private

  def save_new
    if @message.save
			Rails.logger.debug Rails.application.config.action_mailer.smtp_settings
      send_email_message
      redirect_to contact_url
    else
      flash[:danger] = @message.errors.full_messages.to_sentence
      render :new
    end
  end

  def send_email_message
    old_mail_queue = [] << DeliveryGul.deliveries
    DeliveryGul.send_copy_to_sender(@message).deliver_now if params[:copy_to_sender]
    DeliveryGul.send_to_maintainer(@message).deliver_now
    new_mail_queue = DeliveryGul.deliveries 

    if old_mail_queue == new_mail_queue
      flash[:danger] = t('.mailing_service_error')
    else
      flash[:success] = t('.message_successfully_sent') 
    end
  end

  def message_params
    params.require(:message).permit(:sender_name, :sender_email, :subject, :text, :tag)
  end
end
