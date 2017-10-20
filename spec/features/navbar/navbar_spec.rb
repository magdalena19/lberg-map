feature 'Navbar', :js do
  scenario 'Link to map settings in Navbar' do
    skip 'Capy issues'
    map = create :map, :full_public
    visit map_path(map_token: map.secret_token)

    find('.fa-map-o').trigger('click')
    expect(page).to have_content('Map settings')
  end

  scenario 'Link to map settings in Navbar' do
    map = create :map, :full_public, title: 'Two words'
    visit map_path(map_token: map.secret_token)

    expect(page).to have_css('.navbar-logo-green', text: 'Two')
    expect(page).to have_css('.navbar-logo-lilac', text: 'words')
  end
end
