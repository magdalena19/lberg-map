require_relative '../test_helper'

feature 'Contact form' do
	scenario 'Can fill out contact information and click send button', :js do
		visit contact_path
		fill_in_valid_contact_information
		validate_captcha
		click_on 'Send message'
	end

	scenario "Deactivate 'send copy to sender' option if no email address is present", :js do
		visit contact_path
		page.wont_have_content('Send a copy to email address')

		fill_in :message_sender_email, with: 'foo@bar.org'
		page.must_have_content('Send a copy to email address')
	end

	scenario 'Cannot send email if contact information invalid', :js do
		visit contact_path
		fill_in :message_sender_name, with: 'Test Person'
		fill_in :message_sender_email, with: 'test@test.com'
		fill_in :message_subject, with: 'Test subject'
		validate_captcha
		click_on 'Send message'

		page.must_have_content "Text can't be blank"
	end

	def fill_in_valid_contact_information
		find('#message_tag').find(:xpath, 'option[1]').select_option
		fill_in :message_sender_name, with: 'Test Person'
		fill_in :message_sender_email, with: 'test@test.com'
		fill_in :message_subject, with: 'I have a question'
		fill_in('message_text', with: 'This is a sample text')
		check('copy_to_sender')
	end
end
