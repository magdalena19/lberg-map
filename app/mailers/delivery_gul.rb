class DeliveryGul < ApplicationMailer
  default from: AppConfig['maintainer_email_address']

  def send_copy_to_sender(message)
    @message = message
    mail(to: @message.sender_email, subject: "#{t('.request_copy_prefix')} #{AppConfig.general['app_title']}")
  end

  def send_to_maintainer(message)
    @message = message
    mail(to: AppConfig['maintainer_email_address'], subject: "[#{AppConfig.general['app_title']} #{t('.contact_form')}] #{@message.subject}") 
  end
end
