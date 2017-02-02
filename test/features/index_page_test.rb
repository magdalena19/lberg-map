require_relative '../test_helper'

feature 'Index page' do
  scenario 'page has logo and map and language can be set to german', js: true do
    visit root_path

    assert page.must_have_css('.logo')
    assert page.must_have_css('#map')

    page.find('.locale-selection', text: 'Sprache').trigger('click')

    assert page.must_have_content('Alle')
  end
end
