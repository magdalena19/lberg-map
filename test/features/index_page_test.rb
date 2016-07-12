require 'test_helper'

feature 'Index page' do
  scenario 'page has logo and map and language can be switched to german', js: true do
    visit root_path
    sleep(1)
    page.must_have_css('.logo')
    page.must_have_css('#map')
    page.click_on('language')
    sleep(1)
    page.must_have_content('All')
    page.find('.dropdown-toggle', text: 'Language').trigger('click')
    click_link('de')
    page.must_have_content('Alle')
  end
end
