feature 'Create Map', js: true do
  scenario 'as guest user' do
    map = create :map, :full_public
    visit edit_map_path(map_token: map.secret_token)
    fill_in('map_title', with: 'ChangedTitle')
    execute_script("jQuery('.footer').css('display', 'none')") # circumvent button finding prob
    click_on('Update Map')

    expect(map.reload.title).to eq 'ChangedTitle'
  end
end
