require 'test_helper'
# allow tile loading from foreign server
Capybara::Webkit.configure do |config|
  %w[a b c].each { |x| config.allow_url("tile-#{x}.openstreetmap.fr") }
end
# run test headless
Capybara.javascript_driver = :webkit

feature 'Index page' do
  scenario 'Index page is loading' do
    visit_start_page
    see_map_and_logo
  end

  scenario 'language is switched to german' do
    visit_start_page
    switch_to_german
    see_new_place_page
  end

  scenario 'language is switched to german', js: true do
    visit_start_page
    point_to_new_place
    see_prefilled_form_for_new_place
  end

  def see_prefilled_form_for_new_place
    page.must_have_css('form')
    page.must_have_css('.new_place')
    assert_not find_field('place_city').value.nil?
    assert find_field('place_name').value.empty?
  end

  def point_to_new_place
    find('.geocode-button').click
    find("#map").click
  end

  def see_new_place_page
    page.must_have_content('Neuer Ort')
  end

  def switch_to_german
    click_link('de')
  end

  def visit_start_page
    visit root_path
  end

  def see_map_and_logo
    page.must_have_css('.logo')
    page.must_have_css('#map')
  end
end
