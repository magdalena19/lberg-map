class MailerWorker
  include Sidekiq::Worker

  def perform(message_id:, copy_to_sender:)
    @message = Message.find(message_id)
    DeliveryGul.maintainer_mail_copy_to_sender(@message).deliver if copy_to_sender
    DeliveryGul.mail_to_maintainer(@message).deliver
  end
end
