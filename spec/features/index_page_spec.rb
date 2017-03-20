feature 'Index page' do
  scenario 'has logo and map and language can be set to german', js: true do
    create :settings, :public, app_title: 'KARTE'

    visit root_path
    expect(page).to have_css('.logo')
    expect(page).to have_css('#map')
    click_on('Sprache')
    expect(page).to have_content('KARTE')
  end

  scenario 'redirect to login page after selecting language if map is private', :js do
    create :settings, :public, :private

    visit root_path
    expect(page).to have_css('.logo')
    expect(page).to have_css('#map')
    click_on('Sprache')
    expect(page.current_path).to eq("/de/login")
  end
end
