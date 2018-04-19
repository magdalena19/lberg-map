feature 'Modify place categories', js: true do
  before do
    @map = create :map, :full_public
    @place = create :place, :reviewed, categories_string: 'Playground', map: @map
  end

  scenario 'Update and remove category via interface' do
    add_new_category
    assign_category_to_place
    change_priority_order_of_categories
    get_error_after_invalid_category_manipulation
    delete_category
  end

  private

  def add_new_category
    visit_category_editor
    fill_in('map_categories_attributes_1_name_en', with: 'Hospital')
    select('red', from: 'map_categories_attributes_1_marker_color')
    select('circle', from: 'map_categories_attributes_1_marker_shape')
    find('#map_categories_attributes_1_marker_icon_class').trigger('click')
    find('.fa-ambulance').trigger('click')
    find('.submit-place-button').trigger('click')
    expect(page).to have_content('Changes saved')
  end

  def assign_category_to_place
    find('.extra-marker-square-purple').trigger('click')
    expect(page).to have_content('Playground')
    find('.edit-place').trigger('click')
    find('.category.badge', text: 'Hospital').trigger('click')
    find('.submit-place-button').trigger('click')
  end

  def change_priority_order_of_categories
    visit_category_editor
    first('.category-down').trigger('click')
    find('.submit-place-button').trigger('click')
    find('.extra-marker-circle-red').trigger('click')
    expect(page).to have_content('Hospital | Playground')
  end

  def get_error_after_invalid_category_manipulation
    visit_category_editor
    fill_in('map_categories_attributes_0_name_en', with: '')
    find('.submit-place-button').trigger('click')
    expect(page).to have_content('Categories name translation missing')
    click_on('Tags')
    sleep 0.2
    fill_in('map_categories_attributes_1_name_en', with: 'Playground')
  end

  def delete_category
    first('.delete-category').trigger('click')
    find('.submit-place-button').trigger('click')
    find('.extra-marker-square-purple').trigger('click')
    expect(page).to_not have_content('Hospital | Playground')
    expect(page).to have_content('Playground')
  end

  def visit_category_editor
    visit edit_map_path(map_token: @map.secret_token)
    click_on('Tags')
    sleep 0.2
  end
end
