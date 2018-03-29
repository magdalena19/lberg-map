feature 'Modify place categories', js: true do
  before do
    @map = create :map, :full_public
  end

  context 'via place modification' do
    before do
      @place = create :place, :reviewed, categories_string: 'Hospital, Playground', map: @map
      visit map_path(map_token: @map.secret_token)
    end

    scenario 'create category if not there and show in category suggestion' do
      skip "To be implemented"

      add_new_category_via_place_form
      sleep(1)
      expect(Category.count).to eq 3
    end
  end

  context 'via tagging maintainance form' do
    before do
      @place = create :place, :reviewed, categories_string: 'Hospital', map: @map
      visit edit_map_path(map_token: @map.secret_token)
      click_on('Tags')
    end

    scenario 'Update and remove category via interface' do
      change_category_name_and_see_change("Changed")
      remove_category_and_do_not_find_respective_input_field
    end
  end

  private

  def add_new_category_via_place_form
    open_edit_place_modal(id: @place.id)
    fill_in('place_categories_string', with: 'Hospital, Lawyer')
    click_on('Update Place')
  end

  def suggest_new_category_in_search_field
    sleep(1)
    find('#search-input').trigger('click')
    expect(page).to have_content 'Lawyer'
  end

  def change_category_name_and_see_change(new_val)
    find('.name_en').set(new_val)
    find('.update-tag-button').trigger('click')
    sleep(0.1)
    new_value = find('.name_en').value

    expect(new_value).to eq 'Changed'
  end

  def remove_category_and_do_not_find_respective_input_field
    page.accept_confirm do
      find('.delete-tag-button').trigger('click')
    end
    sleep(0.1)

    expect(page).not_to have_css('.name_en')
  end
end
