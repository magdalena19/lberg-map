feature 'Edit description' do
  scenario 'Do not show guest edits in place list', :js do
    skip "Does not show places list panel, dunno why"

    map = create :map, :full_public
    place = create :place, :reviewed, map: map

    visit edit_place_path id: place.id, map_token: map.public_token
    find('h4', text: 'English description').trigger('click')
    fill_in_description_field('Changed description')
    
    click_on('Update Place')

    Capybara.reset_sessions!
    visit map_path(map_token: map.public_token)
    show_places_list_panel
    find(:css, '.name').trigger('click')

    expect(map.reviewed_places.count).to be 1
    expect(page).to have_content(place.name)
    expect(page).not_to have_content('Changed description')
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
