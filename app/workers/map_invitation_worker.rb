class MapInvitationWorker
  include Sidekiq::Worker

  def perform(receiver, email_address, id)
    case receiver
    when 'admin'
      DeliveryGul.delay.invite_collaborator(email_address: email_address, id: id)
    when 'guest'
      DeliveryGul.delay.invite_guest(email_address: email_address, id: id)
    end
  end
end
