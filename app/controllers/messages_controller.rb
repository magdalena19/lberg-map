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
			flash.now[:danger] = t('.invalid_captcha')
			render :new
		end
  end

	private

	def save_new
		if @message.save
			DeliveryGul.send_copy_to_sender(@message).deliver_now if params[:copy_to_sender]
			DeliveryGul.send_to_maintainer(@message).deliver_now
			flash[:success] = "Message successfully sent" 
			redirect_to contact_url
		else
			flash[:warning] = @message.errors
			render :new
		end
	end

	def message_params
		params.require(:message).permit(:sender_name, :sender_email, :subject, :text, :tag)
	end
end
