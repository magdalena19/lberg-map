class DeliveryGul < ApplicationMailer
	default from: ENV['maintainer_email_address']

  def send_copy_to_sender(message)
		@message = message
		mail(to: @message.sender_email, subject: "#{t('.request_copy_prefix')} #{ENV['app_title']}")
  end

	def send_to_maintainer(message)
		@message = message
		mail(to: ENV['maintainer_email_address'], subject: "[#{ENV['app_title']} #{t('.contact_form')}] #{@message.subject}") 
	end
end
