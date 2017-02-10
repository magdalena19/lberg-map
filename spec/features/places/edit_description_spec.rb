feature 'Edit description' do
  scenario 'Do not show guest edits in place list', :js do
    spawn_categories
    place = create :place, :reviewed

    visit edit_place_path id: place.id
    fill_in_description_field('Changed description')
    validate_captcha
    click_on('Update Place')

    Capybara.reset_sessions!
    expect(Place.reviewed_places.count).to be 1

    visit '/places'
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
