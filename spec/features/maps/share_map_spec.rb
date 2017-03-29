feature 'Share map', js: true do
  let(:map) { create :map, :full_public }

  scenario 'as privileged guest user via secret link' do
    skip 'Driver does not properly render form'
    visit share_map_path(map_token: map.secret_token)
    
    page.find('#share_public_link').trigger('click')
    fill_in('map_guests', with: 'foo@bar.org, schnabel@tier.org')
    binding.pry 
    page.find('#share_secret_link').trigger('click')
    fill_in('collaborators', with: 'secret@secret.org')
    click_on('Send invitation')
  end
end
