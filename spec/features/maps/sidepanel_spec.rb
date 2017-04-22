feature 'Sidepanel', :js do
  context 'Place panel buttons' do
    before do
      @map = create :map, :full_public
      @place = create :place, :reviewed, map: @map
    end

    scenario 'can delete place from sidepanel' do
      skip "Capybara does not trigger action"
      visit map_path(map_token: @map.secret_token)
      find('.name').trigger('click')
      page.accept_confirm do
        find('.delete-place').trigger('click')
      end

      expect(page).not_to have_css('.places-list-item')
    end

    scenario 'can delete place from sidepanel' do
      skip "Capybara does not trigger action"
      visit map_path(map_token: @map.secret_token)
      find('.name').trigger('click')
      find('.edit-place').click
      binding.pry 

      # expect(current_path).to eq edit_place_path(map_token: @map.secret_token, id: @place.id)
      expect(page).to have_content 'Edit place'
    end
  end
end
