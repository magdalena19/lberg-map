feature 'Index maps', js: true do
  scenario 'display list as signed in user' do
    login_as_user
    create_list(:map, 3, :full_public, user: User.first) 
    visit maps_path
    expect(page).to have_css('.map-panel', count: 3)
  end

  scenario 'display proper text if no map has been created yet' do
    login_as_user
    visit maps_path
    expect(page).to have_content('You have not created any maps yet...')
  end
end
