feature 'Modify place categories', js: true do
  before do
    @map = create :map, :full_public
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
