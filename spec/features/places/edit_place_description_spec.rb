feature 'Edit description' do
  scenario 'Do not show guest edits in place list', :js do
    map = create :map, :full_public
    place = create :place, :reviewed, map: map, name: 'SomePlace', description: 'Some description'

    visit map_path(map_token: map.public_token)
    open_edit_place_modal(id: place.id)
    find('h4', text: 'English description').trigger('click')
    fill_in_description_field('Changed description')
    
    click_on('Update Place')

    Capybara.reset_sessions!
    visit map_path(map_token: map.public_token)
    show_place_details(name: 'SomePlace')

    expect(page).to have_content('Some description')
  end

  private

  def fill_in_description_field(content)
    # bootsy builds text area via iframe
    within_frame(find('.wysihtml5-sandbox')) do
      query = "document.querySelector('.description-area').innerHTML = '#{content}'"
      page.execute_script(query)
    end
  end
end
