require 'test_helper'

feature 'Index page' do
  scenario 'create valid place' do
    visit '/places/new'
    fill_in_valid_place_information
    click_on('Create place')
    page.must_have_css('.glyphicon-trash')
    page.must_have_content('Any place')
  end

  def fill_in_valid_place_information
    fill_in('place_name', with: 'Any place')
    fill_in('place_street', with: 'Magdalenenstr.')
    fill_in('place_house_number', with: '19')
    fill_in('place_postal_code', with: '10963')
    fill_in('place_city', with: 'Berlin')
    fill_in('captcha', with: 'anycaptchacode')
  end
end
