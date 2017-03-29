class MapInvitationWorker
  include Sidekiq::Worker

  def is_secret_link?(token:)
    Map.find_by(secret_token: token).any?
  end

  def perform(map_token:, email_address:)
    if is_secret_link?(token: map_token)
      DeliveryGul.delay.invite_collaborator(email_address: email_address, map_token: map_token)
    else
      DeliveryGul.delay.invite_guest(email_address: email_address, map_token: map_token)
    end
  end
end
