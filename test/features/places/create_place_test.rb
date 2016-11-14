require_relative '../../test_helper'

feature 'Create place' do
  scenario 'create valid place as user', :js do
    skip('Skip due to Travis CI errors, test works!')
    login
    visit '/places/new'
    fill_in_valid_place_information
    click_on('Create Place')
    visit '/places'
    page.must_have_content('Any place', count: 1)
  end

  scenario 'create valid place as guest', :js do
    skip('Skip due to Travis CI errors, test works!')
    visit '/places/new'
    fill_in_valid_place_information
    fill_in('place_name', with: 'Another place')
    validate_captcha
    click_on('Create Place')
    visit '/places'
    page.must_have_content('Another place')
    page.wont_have_css('.glyphicon-pencil')
  end

  scenario 'visit new place view with coordinate parameters' do
    visit '/places/new?longitude=1&latitude=1' # coordinate values do not matter, because response is mocked
    assert find_field('place_city').value == 'Berlin'
  end

  def fill_in_valid_place_information
    fill_in('place_name', with: 'Any place')
    fill_in('place_street', with: 'Magdalenenstr.')
    fill_in('place_house_number', with: '19')
    fill_in('place_postal_code', with: '10963')
    fill_in('place_city', with: 'Berlin')
    fill_in('place_email', with: 'schnipp@schnapp.com')
    fill_in('place_homepage', with: 'http://schnapp.com')
    fill_in('place_phone', with: '03081763253')
  end
end
