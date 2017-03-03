class DeliveryGul < ApplicationMailer
  def send_copy_to_sender(message)
    @message = message
    mail(
      from: Admin::Setting.maintainer_email_address,
      to: @message.sender_email,
      subject: "#{t('.request_copy_prefix')} #{Admin::Setting.app_title}"
    )
  end

  def send_to_maintainer(message)
    @message = message
    mail(
      from: Admin::Setting.maintainer_email_address,
      to: Admin::Setting.maintainer_email_address,
      subject: "[#{Admin::Setting.app_title} #{t('.contact_form')}] #{@message.subject}"
    )
  end

  def send_password_reset_link(user)
    @user = user
    @password_reset_link = reset_password_url id: @user.id, token: @user.password_reset_token
    mail(from: Admin::Setting.maintainer_email_address, to: user.email, subject: "Password reset for #{Admin::Setting.app_title}")
  end
end
