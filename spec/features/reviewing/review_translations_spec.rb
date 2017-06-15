feature 'Review translations', :js do
  before do
    @map = create :map, :full_public
    @place = create :place, :reviewed, map: @map
  end

  scenario 'Show guest edits in review index and review place' do
    visit edit_place_path id: @place.id, map_token: @map.public_token
    find('h4', text: 'English description').trigger('click')
    fill_in_description_field('ChangedDescription')
    
    click_on('Update Place')
    login_as_user
    visit places_review_index_path(map_token: @map.secret_token)

    expect(page).to have_content('ChangedDescription')

    visit review_translation_path id: @place.id, map_token: @map.secret_token

    click_on('Confirm')
    expect(@place.reload.description_en).to eq 'ChangedDescription'
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
