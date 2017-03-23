feature 'Contact form' do
  before do
    map = create :map, :full_public, maintainer_email_address: 'foo@bar.org'
    visit contact_path(map_token: map.public_token)
  end

  scenario 'Can fill out contact information and click send button', :js do
    fill_in_valid_contact_information
    validate_captcha
    click_on 'Send message'
  end

  scenario "Deactivate 'send copy to sender' option if no email address is present", :js do
    expect(page).to_not  have_content('Send a copy to email address')

    fill_in :message_sender_email, with: 'foo@bar.org'
    expect(page).to have_content('Send a copy to email address')
  end

  def fill_in_valid_contact_information
    fill_in :message_sender_name, with: 'Test Person'
    fill_in :message_sender_email, with: 'test@test.com'
    fill_in :message_subject, with: 'I have a question'
    fill_in('message_text', with: 'This is a sample text')
    check('copy_to_sender')
  end
end
