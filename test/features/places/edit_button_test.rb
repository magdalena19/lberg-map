require 'test_helper'

feature 'edit buttons' do
  scenario 'are visible when logged in', js: true do
    login
    page.find('.show-places').trigger('click')
    sleep(1)
    page.must_have_css('.edit-place')
  end

  def login
    visit login_path
    fill_in 'User email', with: 'susanne@example.com'
    fill_in 'Password', with: 'secret'
    click_on 'Login'
  end
end
