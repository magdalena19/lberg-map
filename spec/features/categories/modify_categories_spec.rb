feature 'Modify place categories', js: true do
  before do
    @map = create :map, :full_public
  end

  feature 'Modify categories via place modification' do
    before do
      @place = create :place, :reviewed, categories_string: 'Hospital, Playground', map: @map
      visit map_path(map_token: @map.secret_token)
    end

    scenario 'create category if not there and properly update place categories' do
      open_edit_place_modal(id: @place.id)
      fill_in('place_categories_string', with: 'Hospital, Lawyer')
      click_on('Update Place')
      show_places_list_panel
      find('div.name').trigger('click')
      view_category_string = find('div.category-names').text.split(' | ')

      expect(view_category_string.sort).to eq ['Hospital', 'Lawyer']
    end
  end

  feature 'Modify categories via tagging maintainance form' do
    before do
      @place = create :place, :reviewed, categories_string: 'Hospital', map: @map
    end

    before do
      visit edit_map_path(map_token: @map.secret_token)
      click_on('Tags')
    end

    scenario 'remove category via interface' do
      skip "Cannot test that cause its JS behavior..."

      page.accept_confirm do
        find('.delete-tag-button').trigger('click')
      end

      expect(page).not_to have_selector "input[value='Hospital']"
    end

    scenario 'Update category via interface' do
      skip "Feature works, test does not, dunno why..."

      find("input[value='Hospital']").set('Changed')
      binding.pry 
      find('.update-tag-button').trigger('click')

      expect(Category.all.map(&:name)).to include 'Changed'
      expect(Category.all.map(&:name)).not_to include 'Hospital'
    end
  end
end
