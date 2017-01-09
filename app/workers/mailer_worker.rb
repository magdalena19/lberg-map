class MailerWorker
  include Sidekiq::Worker

  def perform(message_id:, copy_to_sender:)
    @message = Message.find(message_id)
    binding.pry
    DeliveryGul.delay.send_copy_to_sender(@message).deliver_now if copy_to_sender
    DeliveryGul.delay.send_to_maintainer(@message).deliver_now
  end
end
