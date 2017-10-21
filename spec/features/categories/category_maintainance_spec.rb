feature 'Modify categories via tagging maintainance form', js: true do
  before do
    @map = create :map, :full_public
    @place = create :place, :reviewed, categories_string: 'Hospital', map: @map
    visit edit_map_path(map_token: @map.secret_token)
    click_on('Tags')
  end

  scenario 'remove category via interface' do
    page.accept_confirm do
      find('.delete-tag-button').trigger('click')
    end

    sleep(1)
    expect(page).not_to have_selector "input[value='Hospital']"
  end

  scenario 'Update category via interface' do
    find('.name_en').set('Changed')
    find('.update-tag-button').trigger('click')

    sleep(1)
    new_val = find('.name_en').value
    expect(new_val).to eq 'Changed'
  end
end
