require 'test_helper'

feature 'Index page' do
  scenario 'Index page is loading' do
    visit_start_page
    see_map_and_logo
  end

  scenario 'language is switched to german' do
    visit_start_page
    switch_to_german
    see_german_link
  end

  def see_german_link
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
