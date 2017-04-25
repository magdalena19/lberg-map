feature 'Contact form' do
  scenario 'opens explanation modal when clicked on question mark icon', :js do
    visit landing_page_path
    find('.glyphicon-question-sign').trigger('click')
    expect(page).to have_content('This is the quick and easy way to create a new map')
    click_on 'Okay'
    expect(page).to_not have_content('This is the quick and easy way to create a new map')
  end
end
