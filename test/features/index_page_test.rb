require 'test_helper'

feature 'Index page' do
  before do
    create(:place, :reviewed)
  end

  scenario 'page has logo and map and language can be set to german', js: true do
    visit root_path
    page.must_have_css('.logo')
    page.must_have_css('#map')
    page.find('.btn', text: 'Sprache').trigger('click')
    page.must_have_content('Alle')
  end
end
