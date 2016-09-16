require 'test_helper'

feature 'edit buttons' do
  scenario 'are visible when logged in', js: true do
    login
    page.find('.show-places').trigger('click')
    sleep(1)
    page.must_have_css('.edit-place')
  end
end
