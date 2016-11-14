require_relative '../test_helper'

feature 'Contact form' do
	scenario 'Contact form is present' do
		visit contact_path

		fill_in_valid_contact_information
	end

	scenario 'Can send email if contact information valid', :js do
		assert_difference 'Message.count' do
			visit contact_path

			fill_in_valid_contact_information
			click_on 'Send message'
		end

		assert_equal Message.last.tag, 'Technical question'
		page.must_have_content 'Message successfully sent'
	end

	scenario 'Send two emails if mail copy option checked in contact form', :js do
		assert_difference 'Message.count', 2 do
			visit contact_path
			fill_in_valid_contact_information
			check('copy_to_sender')

			click_on 'Send message'
		end
	end

	scenario 'Cannot send email if contact information invalid', :js do
		visit contact_path
		screenshot_and_open_image
		# save_and_open_page

		fill_in :message_sender_name, with: 'Test Person'
		fill_in :message_sender_email, with: 'test@test.com'

		click_on 'Send message'
		page.wont_have_content 'Message successfully sent'
	end

	def fill_in_valid_contact_information
		find('#message_tag').find(:xpath, 'option[1]').select_option
		fill_in :message_sender_name, with: 'Test Person'
		fill_in :message_sender_email, with: 'test@test.com'
		fill_in :message_subject, with: 'I have a question'
		fill_in('message_text', with: 'This is a sample text')
	end
end
