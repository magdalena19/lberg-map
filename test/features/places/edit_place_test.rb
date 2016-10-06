require 'test_helper'

feature 'Edit place' do
  scenario 'Do valid place update as user and show in index afterwards', :js do
    login
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

  scenario 'Do valid place update as guest and mark point to be reviewed in index within session', :js do
    skip('Implement storing updates in session cookies')
    visit '/places/1/edit'
    fill_in('place_name', with: 'Some changes')
    validate_captcha
    click_on('Update Place')
    visit '/places'
    page.wont_have_content('Some changes')
    page.must_have_content('Hausprojekt Magdalenenstraße')
    page.must_have_content('Waiting for review')
  end
end
