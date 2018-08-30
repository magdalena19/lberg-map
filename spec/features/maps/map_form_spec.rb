feature 'Map form', js: true do
  context 'Edit map' do
    before do
      execute_script("jQuery('.footer').css('display', 'none')") # circumvent button finding prob
      @map = create :map, :full_public, :autopost_twitter
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

    scenario 'it creates private map without public token and is_public flag false' do
      create_new_map_and_expect_public_flags_to_be_nil
      visit_map_and_do_not_find_embedded_link
    end

    scenario 'it can update valid secret token' do
      set_secret_token_eq_public_token_and_find_error
      set_valid_secret_token_successfully
    end

    scenario 'it can update valid public token' do
      set_public_token_eq_secret_token_and_find_error
      set_valid_public_token_successfully
    end

    scenario 'it can toggle twitter autopost' do
      click_on 'Publication settings'
      find('#map_autopost_twitter').set(false)
      click_on 'Update'
      expect(@map.reload.autopost_twitter).to eq false
    end

    private

    def set_valid_public_token_successfully
      click_on 'Publication settings'
      fill_in 'map_public_token', with: 'some_token'
      click_on 'Update'
      expect(@map.reload.public_token).to eq 'some_token'
    end

    def set_valid_secret_token_successfully
      fill_in 'map_secret_token', with: 'some_token'
      click_on 'Update'
      expect(page).to have_css('.alert-success')
      expect(@map.reload.secret_token).to eq 'some_token'
    end

    def set_public_token_eq_secret_token_and_find_error
      click_on 'Publication settings'
      fill_in 'map_public_token', with: @map.secret_token
      click_on 'Update'
      expect(page).to have_css('.alert-danger')
    end

    def set_secret_token_eq_public_token_and_find_error
      fill_in 'map_secret_token', with: @map.public_token
      click_on 'Update'
      expect(page).to have_css('.alert-danger')
    end

    def create_new_map_and_expect_public_flags_to_be_nil
      Map.destroy_all
      visit new_map_path
      click_on 'Create Map'
      expect(page).to have_css '.map-container'
      @map = Map.first
      expect(@map.is_public).not_to be true
      expect(@map.public_token).to eq ''
    end

    def visit_map_and_do_not_find_embedded_link
      visit map_path(map_token: @map.secret_token)
      find('.share-map').trigger('click')
      expect(page).not_to have_css('iframe')
    end

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
