feature 'Update place categories' do
  scenario 'create category if not there and properly update place categories', :js do
    @map = create :map, :full_public
    @place = create :place, :reviewed, categories: 'Hospital, Playground', map: @map
    login_as_user
    visit edit_place_path(id: @place.id, map_token: @map.public_token)

    fill_in('place_categories', with: 'Hospital, Lawyer')
    click_on('Update Place')
    new_category_string = @place.reload.category_names.join(',')

    expect(@map.category_names_list).to include('Lawyer')
    expect(new_category_string).to eq 'Hospital,Lawyer'
  end
end
