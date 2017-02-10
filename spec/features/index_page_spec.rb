feature 'Index page' do
  scenario 'page has logo and map and language can be set to german', js: true do
    visit root_path
    expect(page).to have_css('.logo')
    expect(page).to have_css('#map')
    click_on('Sprache')
    expect(page).to have_content('Alle')
  end
end
