class WelcomeUserWorker
  include Sidekiq::Worker

  def perform(id)
    DeliveryGul.delay.send_welcome_mail(user_id: id)
  end
end
