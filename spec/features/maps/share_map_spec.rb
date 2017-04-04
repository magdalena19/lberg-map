feature 'Share map', js: true do
  let(:map) { create :map, :full_public }

  scenario 'as privileged guest user via secret link' do
    visit share_map_path(map_token: map.secret_token)
    
    fill_in('map_guests', with: 'foo@bar.org, schnabel@tier.org')
    page.find('#share_admin_link').trigger('click')
    fill_in('map_admins', with: 'secret@secret.org')
    click_on('Send invitation')
  end

  scenario 'Disable text field if map not public' do
    private_map = create :map, :private
    visit share_map_path(map_token: private_map.secret_token)

    map_guests_field = page.find('#map_guests')
    expect(map_guests_field.disabled?).to be true
  end

  scenario 'Enables map admins field on link click' do
    private_map = create :map, :private
    visit share_map_path(map_token: private_map.secret_token)

    page.find('#share_admin_link').trigger('click')
    expect(page).to have_css('#map_admins')
  end
end
