class DeliveryGul < ApplicationMailer
  default from: AppConfig.general['maintainer_email_address']

  def send_copy_to_sender(message)
		# logger.debug Rails.application.config.action_mailer.smtp_settings
    @message = message
    mail(to: @message.sender_email, subject: "#{t('.request_copy_prefix')} #{AppConfig.general['app_title']}")
  end

  def send_to_maintainer(message)
    @message = message
    mail(to: AppConfig.general['maintainer_email_address'], subject: "[#{AppConfig.general['app_title']} #{t('.contact_form')}] #{@message.subject}") 
  end
end
