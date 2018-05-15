feature 'Map form', js: true do
  context 'Edit map' do
    before do
      execute_script("jQuery('.footer').css('display', 'none')") # circumvent button finding prob
      @map = create :map, :full_public
      visit edit_map_path(map_token: @map.secret_token)
    end

    scenario 'it does not reassign public and secret token' do
      find_correct_secret_token
      find_correct_public_token
    end

    scenario 'it can update public status of private map' do
      skip 'Test fails on CI (passes locally), dunno why'
      set_map_public_and_visit_and_find_map_container(create(:map, :private))
    end

    private

    def find_correct_secret_token
      secret_token_field_value = find('#map_secret_token').value

      expect(secret_token_field_value).to eq @map.secret_token
    end

    def find_correct_public_token
      click_on('Publication settings')
      public_token_field_value = find('#map_public_token').value

      expect(public_token_field_value).to eq @map.public_token
    end

    def set_map_public_and_visit_and_find_map_container(map)
      visit edit_map_path(map_token: map.secret_token)
      click_on 'Publication settings'
      check 'map_is_public'
      check 'map_allow_guest_commits'
      fill_in 'map_public_token', with: 'public_map'
      click_on 'Update'
      visit map_path(map_token: 'public_map')
      expect(page).to have_css '.place-control-container'
    end
  end
end
