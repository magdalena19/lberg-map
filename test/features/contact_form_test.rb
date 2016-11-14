require_relative '../test_helper'

feature 'Contact form' do
	scenario 'Contact form is present' do
		visit contact_path

		fill_in_valid_contact_information
	end

	scenario 'Can send email if contact information valid', js: true do
		assert_difference 'Message.count' do
			visit contact_path

			fill_in_valid_contact_information
			click_on 'Submit'
		end
		page.must_have_content 'Message successfully sent'
	end

	scenario 'Cannot send email if contact information invalid', js: true do
		visit contact_path

		fill_in :message_sender_name, with: 'Test Person'
		fill_in :message_sender_email, with: 'test@test.com'

		click_on 'Submit'
		page.wont_have_content 'Message successfully sent'
	end

	def fill_in_valid_contact_information
		fill_in :message_sender_name, with: 'Test Person'
		fill_in :message_sender_email, with: 'test@test.com'
		fill_in :message_subject, with: 'I have a question'
		fill_in :message_text, with: 'This is some sample text'
	end
end
