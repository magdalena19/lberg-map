require 'test_helper'

feature 'Review place' do
  scenario 'Do not show user edits in review index', :js do
    login
    visit '/places/1/edit'
    fill_in('place_name', with: 'USER CHANGE')
    click_on('Update place')
    visit '/places/review_index'
    page.wont_have_content('USER CHANGE')
  end

  scenario 'Show guest edits in review index and review place', :js do
    visit '/places/1/edit'
    fill_in('place_name', with: 'GUEST CHANGE')
    validate_captcha
    click_on('Update place')
    login
    visit '/places/review_index'
    page.must_have_content('GUEST CHANGE')
    visit '/1/review_place'
    page.must_have_content('GUEST CHANGE')
  end

  def login
    visit login_path
    fill_in 'User email', with: 'admin@example.com'
    fill_in 'Password', with: 'secret'
    click_on 'Login'
  end

  def validate_captcha
    fill_in 'captcha', with: SimpleCaptcha::SimpleCaptchaData.first.value
  end
end
