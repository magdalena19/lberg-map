class DeliveryGul < ApplicationMailer
  default from: AppConfig['maintainer_email_address']

  def send_copy_to_sender(message)
    @message = message
    mail(
      to: @message.sender_email,
      subject: "#{t('.request_copy_prefix')} #{AppConfig.general['app_title']}"
    )
  end

  def send_to_maintainer(message)
    @message = message
    mail(
      to: AppConfig['maintainer_email_address'],
      subject: "[#{AppConfig.general['app_title']} #{t('.contact_form')}] #{@message.subject}"
    )
  end

  def send_password_reset_link(user)
    @user = user
    @password_reset_link = reset_password_url id: @user.id, token: @user.password_reset_token
    # TODO translate
    mail(to: user.email, subject: 'Password zurücksetzen') 
  end
end
