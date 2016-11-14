require_relative '../../test_helper'

feature 'Edit description' do
  before do
    @place = create(:place, :reviewed)
  end

  scenario 'Do not show guest edits in place list', :js do
    visit edit_place_path id: @place.id
    fill_in_description_field('Changed description')
    validate_captcha
    click_on('Update Place')

    Capybara.reset_sessions!
    assert_equal 1, Place.reviewed.count

    sleep(1)
    visit '/places'
    page.must_have_content @place.name
    page.find('.glyphicon-triangle-bottom').trigger('click')
    page.wont_have_content('Changed description')

  end

  private

  def fill_in_description_field(content)
    # bootsy builds text area via iframe
    within_frame(find('.wysihtml5-sandbox')) do
      query = "document.querySelector('.description-area').innerHTML = '#{content}'"
      page.execute_script(query)
    end
  end

  # scenario 'Show guest edits in review index and review place', :js do
  #   visit edit_place_path id: @place.id
  #   fill_in('place_name', with: 'GUEST CHANGE')
  #   validate_captcha
  #   click_on('Update Place')
  #   sleep(1)
  #   login
  #   visit '/places/review_index'
  #   page.must_have_content('SomeReviewedPlace')

  #   visit review_place_path id: @place.id
  #   sleep(1)
  #   page.must_have_content('SomeReviewedPlace')
  #   page.must_have_content('GUEST CHANGE')
  # end
end
