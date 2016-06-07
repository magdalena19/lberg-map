require 'test_helper'

# allow tile loading from foreign server
Capybara::Webkit.configure do |config|
  %w[a b c].each { |x| config.allow_url("tile-#{x}.openstreetmap.fr") }
end

# run test headless
Capybara.javascript_driver = :webkit

feature 'Reverese geocoder' do
  scenario 'new place prefilled form is loaded', js: true do
    visit_start_page
    point_to_new_place
    redirect_to_new_place_form
  end

  def visit_start_page
    visit root_path
  end

  def point_to_new_place
    find('.geocode-button').click
    find('#map').click
  end

  def redirect_to_new_place_form
    page.must_have_css('form')
    page.must_have_css('.new_place')
    assert find_field('place_city').value == 'Berlin'
    assert find_field('place_name').value.empty?
  end
end
