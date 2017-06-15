feature 'Edit description' do
  scenario 'Do not show guest edits in place list', :js do
    skip 'Map rendering issue'
    map = create :map, :full_public
    place = create :place, :reviewed, map: map

    visit edit_place_path id: place.id, map_token: map.public_token
    find('h4', text: 'English description').trigger('click')
    fill_in_description_field('Changed description')
    
    click_on('Update Place')

    Capybara.reset_sessions!
    expect(map.reviewed_places.count).to be 1

    show_places_index(map_token: @map.public_token)
    expect(page).to have_content(place.name)
    page.find('.glyphicon-triangle-bottom').trigger('click')
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
