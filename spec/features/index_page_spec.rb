feature 'Index page' do
  scenario 'page has logo and map and language can be set to german', js: true do
    visit root_path
    page.must_have_css('.logo')
    page.must_have_css('#map')
    click_on('Sprache')
    page.must_have_content('Alle')
  end
end
