feature 'Update place categories' do
  before do
    create :settings, :public
    @place = create :place, :reviewed, categories: 'Hospital, Playground'
  end

  scenario 'create category if not there and properly update place categories', :js do
    login_as_user
    visit edit_place_path(id: @place.id)

    fill_in('place_categories', with: 'Hospital, Lawyer')
    click_on('Update Place')
    expect(Category.count).to eq 3
    expect(@place.reload.categories).to eq '2,3'
  end
end
