require_relative '../../test_helper'

feature 'Create place' do
  scenario 'create valid place as user', :js do
    login
    visit '/places/new'
    fill_in_valid_place_information
    click_on('Create Place')
    visit '/places'
    page.must_have_content('Any place', count: 1)
  end

  scenario 'create valid place as guest', :js do
    create_place_as_guest('Another place')
    visit '/places'
    page.must_have_content('Another place')
    page.wont_have_css('.glyphicon-pencil')
  end

  scenario 'see guests session places on map', :js do
    create_place_as_guest('Another place')
    create_place_as_guest('Still another place')
    visit '/en'
    sleep(1)
    assert page.must_have_content('Another place')
    assert page.must_have_content('Still another place')
  end

  scenario 'visit new place view with coordinate parameters' do
    visit '/places/new?longitude=1&latitude=1' # coordinate values do not matter, because response is mocked
    assert find_field('place_city').value == 'Berlin'
  end

  scenario 'show only one wysiwyg editor for current locale', :js do
    visit '/places/new'
    page.must_have_css('.wysihtml5-toolbar', count: 1)
    page.find('.glyphicon-triangle-bottom').click
    page.must_have_css('.wysihtml5-toolbar', count: 2)
  end

  def create_place_as_guest(place_name)
    visit '/places/new'
    fill_in_valid_place_information
    fill_in('place_name', with: place_name)
    validate_captcha
    click_on('Create Place')
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
