require 'test_helper'

feature 'Edit place' do
  scenario 'Do valid place update as user and show in index afterwards', :js do
    login
    visit '/places'
    # screenshot_and_open_image
    debugger
    visit '/places/1/edit'

    fill_in('place_name', with: 'Any place')
    fill_in('place_street', with: 'Schulze-Boysen-Str.')
    fill_in('place_house_number', with: '80')
    fill_in('place_postal_code', with: '10963')
    fill_in('place_city', with: 'Berlin')
    fill_in('place_email', with: 'schnipp@schnapp.com')
    fill_in('place_homepage', with: 'http://schnapp.com')
    fill_in('place_phone', with: '03081763253')
    click_on('Update Place')
    visit '/places'

    page.must_have_content('Any place')
    page.must_have_content('10963 Berlin')
  end

  scenario 'Do valid place update as guest and show in index afterwards as to be reviewed', :js do
    visit '/places/1/edit'
    fill_in('place_name', with: 'Some changes')
    validate_captcha
    click_on('Update Place')
    visit '/places'

    page.must_have_content('Some changes')
    page.must_have_css('.glyphicon-eye-open')
  end

  scenario 'Do valid place update as guest and do not show changes within other users session', :js do
    visit '/places/1/edit'
    fill_in('place_name', with: 'Some changes')
    validate_captcha
    click_on('Update Place')

    Capybara.reset_sessions!
    visit '/places'
    # screenshot_and_open_image
    page.wont_have_content('Some changes')
    page.must_have_content('Hausprojekt Magdalenenstraße')
    page.wont_have_css('.glyphicon-eye-open')
  end
end
