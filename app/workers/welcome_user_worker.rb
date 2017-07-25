class WelcomeUserWorker
  include Sidekiq::Worker

  def perform(id)
    DeliveryGul.welcome_mail(user_id: id).deliver
  end
end
