feature 'Navbar', :js do
  scenario 'Link to map settings in Navbar' do
    # Setup new map
    visit new_map_path
    map_token = SecureRandom.hex
    find('#map_secret_token').set(map_token)
    find('#map_title').set('Two words')
    create_map
    visit map_path(map_token: map_token)

    # Display correct logo
    expect(page).to have_css('.navbar-logo-green', text: 'Two')
    expect(page).to have_css('.navbar-logo-lilac', text: 'words')

    # Link to map settings
    find('.fa-map-o').trigger('click')
    expect(page).to have_content('Map settings')
  end
end
