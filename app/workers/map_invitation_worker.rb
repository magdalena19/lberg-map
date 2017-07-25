class MapInvitationWorker
  include Sidekiq::Worker

  def perform(receiver, email_address, id)
    case receiver
    when 'admin'
      DeliveryGul.invite_collaborator(email_address: email_address, id: id).deliver
    when 'guest'
      DeliveryGul.invite_guest(email_address: email_address, id: id).deliver
    end
  end
end
