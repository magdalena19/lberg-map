feature 'Update place categories' do
  before do
    create :settings, :public
    @place = create :place, :reviewed, categories: 'Hospital, Playground'
  end

  scenario 'create category if not there', :js do
    login_as_user
    visit edit_place_path(id: @place.id)

    fill_in('place_categories', with: 'Hospital, Lawyer')
    click_on('Update Place')
    new_category_string = @place.reload.category_names.join(',')

    expect(Category.list_names).to include('Lawyer')
  end

  scenario 'create category if not there and properly update place categories', :js do
    login_as_user
    visit edit_place_path(id: @place.id)

    fill_in('place_categories', with: 'Hospital, Lawyer')
    click_on('Update Place')
    new_category_string = @place.reload.category_names.join(',')

    expect(new_category_string).to eq 'Hospital,Lawyer'
  end
end
