require 'test_helper'

feature 'Admin edit buttons' do
  scenario 'are not visible when not logged in', js: true do
    visit root_path
    page.find('.show-places').click
    sleep(1)
    page.wont_have_css('.edit-place')
  end

  scenario 'are not visible when logged in as non-admin', js: true do
    login_as_non_admin
    page.find('.show-places').click
    sleep(1)
    page.wont_have_css('.edit-place')
  end

  scenario 'are visible when admin and link to editor', js: true do
    login_as_admin
    page.find('.show-places').click
    sleep(1)
    page.must_have_css('.edit-place')
  end

  def login_as_non_admin
    visit login_path
    fill_in 'User email', with: 'susanne@example.com'
    fill_in 'Password', with: 'secret'
    click_on 'Login'
  end

  def login_as_admin
    visit login_path
    fill_in 'User email', with: 'admin@example.com'
    fill_in 'Password', with: 'secret'
    click_on 'Login'
  end
end
