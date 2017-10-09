feature 'Review place', :js do
  before(:each) do
    @map = create :map, :full_public 
    @place = create :place, :reviewed, name: 'Some reviewed place', map: @map
  end

  context 'Privileged user' do
    scenario 'user inputs do not have to be reviewed' do
      visit map_path(map_token: @map.secret_token)
      open_edit_place_modal(id: @place.id)
      fill_in('place_name', with: 'USER CHANGE')
      click_on('Update Place')
      visit places_review_index_path(map_token: @map.secret_token)

      expect(page).not_to have_content('USER CHANGE')
    end
  end

  feature 'Guest edits' do
    before do
      visit map_path(map_token: @map.public_token)
      open_edit_place_modal(id: @place.id)
      fill_in('place_name', with: 'GUEST CHANGE')
      click_on('Update Place')

      sleep(2)
      login_as_user
    end

    scenario 'Show guest edits in review index and review place' do
      visit places_review_index_path(map_token: @map.secret_token)

      expect(find_all('td', text: 'GUEST CHANGE')).not_to be_empty
    end

    scenario 'Shows correct details to be reviewed' do
      binding.pry if @place.versions.count == 1
      visit review_place_path(id: @place.id, map_token: @map.secret_token)

      expect(page).to have_content('GUEST CHANGE')
    end
  end
end
