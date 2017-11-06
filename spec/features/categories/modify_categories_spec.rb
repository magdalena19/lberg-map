feature 'Modify place categories', js: true do
  before do
    @map = create :map, :full_public
  end

  context 'via place modification' do
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

  context 'via tagging maintainance form' do
    before do
      @place = create :place, :reviewed, categories_string: 'Hospital', map: @map
      visit edit_map_path(map_token: @map.secret_token)
      click_on('Tags')
    end

    scenario 'remove category via interface' do
      page.accept_confirm do
        find('.delete-tag-button').trigger('click')
      end
      sleep(1)

      expect(page).not_to have_css('.name_en')
    end

    scenario 'Update category via interface' do
      find('.name_en').set("Changed")
      find('.update-tag-button').trigger('click')
      sleep(1)
      new_value = find('.name_en').value
      
      expect(new_value).to eq 'Changed'
    end
  end

  context 'Add categories via tagging maintainance form' do
    # TODO implment that!
    scenario 'can add categories to new maps' do
      skip 'To be implemented'
      visit new_map_path
    end
  end
end
