class DeliveryGul < ApplicationMailer
	default from: ENV['maintainer_email_address']

  def send_copy_to_sender(message)
		debugger
		@message = message
		mail(to: @message.sender_email, subject: t('.copy_to_sender_subject'))
  end

	def send_to_maintainer(message)
		@message = message
		mail(to: ENV['maintainer_email_address'], subject: t('.contact_request_subject') + @message.subject)
	end
end
