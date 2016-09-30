require 'test_helper'

feature 'edit buttons' do
  scenario 'are visible when logged in', js: true do
    skip('Since we do not have places-sliderpanel, we have to test the button on a place-slideplanel - how to open it here without clicking marker?')
    login
    page.find('.show-places').trigger('click')
    sleep(1)
    page.must_have_css('.edit-place')
  end
end
