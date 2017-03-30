describe DeliveryGul do
  before do
    @map = create :map, :full_public, maintainer_email_address: 'maintainer@map.org'
    @anonymous_map = create :map, :full_public
    @message = create :message, map: @map, sender_name: 'Me', sender_email: 'foo@bar.org', subject: 'it subject', text: 'Test text'
  end

  it 'send copy to sender' do
    email = DeliveryGul.send_copy_to_sender(@message).deliver_now

    expect(ActionMailer::Base.deliveries.empty?).to be false
    expect(email.from).to eq [@map.maintainer_email_address]
    expect(email.to).to eq ['foo@bar.org']
    expect(email.subject).to eq "Copy of your request on #{@map.title}"
  end

  it 'send to maintainer' do
    email = DeliveryGul.send_to_maintainer(@message).deliver_now

    expect(ActionMailer::Base.deliveries.empty?).to be false
    expect(email.from).to eq [@map.maintainer_email_address]
    expect(email.to).to eq [@map.maintainer_email_address]
    expect(email.subject).to eq "[#{@map.title} contact form] #{@message.subject}"
  end

  context 'Map invitation' do
    before do
      create :settings, admin_email_address: 'admin@test.com'
    end

    it 'invites collaborators' do
      email = DeliveryGul.invite_collaborator(map_token: @map.secret_token, email_address: 'foo@bar.com').deliver_now
      user = create :user, email: 'user@foo.bar'

      expect(ActionMailer::Base.deliveries.empty?).to be false
      expect(email.reply_to).to eq [@map.maintainer_email_address]
      expect(email.from).to eq [Admin::Setting.admin_email_address]
      expect(email.to).to eq ['foo@bar.com']
      expect(email.subject).to eq "You've been invited to collaborate on '#{@map.title}'-map!"
      expect(email.body).to match map_url(map_token: @map.secret_token)
    end

    it 'invites guest' do
      email = DeliveryGul.invite_guest(map_token: @map.public_token, email_address: 'foo@bar.com').deliver_now
      user = create :user, email: 'user@foo.bar'

      expect(ActionMailer::Base.deliveries.empty?).to be false
      expect(email.from).to eq [Admin::Setting.admin_email_address]
      expect(email.reply_to).to eq [@map.maintainer_email_address]
      expect(email.to).to eq ['foo@bar.com']
      expect(email.body).to match map_url(map_token: @map.public_token)
      expect(email.subject).to eq "You've been invited to have a look at '#{@map.title}'-map!"
      expect(email.body).not_to match map_url(map_token: @map.secret_token)
    end
  end

  context 'User stuff' do
    it 'sends password reset link' do
      create :settings, admin_email_address: 'admin@foo.bar'
      user = create :user, email: 'user@foo.bar'
      user.create_digest_for(attribute: 'password_reset')
      email = DeliveryGul.send_password_reset_link(user).deliver_now

      expect(ActionMailer::Base.deliveries.empty?).to be false
      expect(email.from).to eq [Admin::Setting.admin_email_address]
      expect(email.to).to eq [user.email]
      expect(email.subject).to eq "Password reset for #{Admin::Setting.app_title}"
      expect(email.body).to match user.password_reset_token
    end

    it 'send welcome message' do
      create :settings, admin_email_address: 'admin@foo.bar'
      user = create :user, email: 'user@foo.bar'
      email = DeliveryGul.send_welcome_mail(user_id: user.id).deliver_now

      expect(ActionMailer::Base.deliveries.empty?).to be false
      expect(email.from).to eq [Admin::Setting.admin_email_address]
      expect(email.to).to eq [user.email]
      expect(email.subject).to eq "Welcome to #{Admin::Setting.app_title}"
      expect(email.body).to match 'Hello'
      expect(email.body).to match maps_url

    end
  end
end
