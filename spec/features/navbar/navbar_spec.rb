feature 'Navbar', :js do
  scenario 'Link to map settings in Navbar' do
    login_as_user
    map = create :map, :full_public
    visit map_path(map_token: map.secret_token)

    find('.fa-map-o').trigger('click')

    expect(page).to have_content('Map settings')
  end
end
