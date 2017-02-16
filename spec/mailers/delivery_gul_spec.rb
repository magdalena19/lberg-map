describe DeliveryGul do
  before do
    @message = Message.new(sender_name: 'Me', sender_email: 'foo@bar.org', subject: 'it subject', text: 'Test text')
    create :settings
  end

  it 'send copy to sender' do
    email = DeliveryGul.send_copy_to_sender(@message).deliver_now

    expect(ActionMailer::Base.deliveries.empty?).to be false

    # it the body of the sent email contains what we expect it to
    expect(email.from).to eq [Admin::Setting.maintainer_email_address]
    expect(email.to).to eq ['foo@bar.org']
    expect(email.subject).to eq "Copy of your request on #{Admin::Setting.app_title}"
  end

  it 'send to maintainer' do
    email = DeliveryGul.send_to_maintainer(@message).deliver_now

    expect(ActionMailer::Base.deliveries.empty?).to be false

    # it the body of the sent email contains what we expect it to
    expect(email.from).to eq [Admin::Setting.maintainer_email_address]
    expect(email.to).to eq [Admin::Setting.maintainer_email_address]
    expect(email.subject).to eq "[#{Admin::Setting.app_title} contact form] #{@message.subject}"
  end
end
