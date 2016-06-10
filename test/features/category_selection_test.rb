require 'test_helper'

feature 'Category selection' do
  before do
    Category.new( name_en: 'Playground', name_de: 'Spielplatz', name_fr: 'Spielplatz', name_ar: 'Spielplatz' ).save
  end

  scenario 'Place is shown when \'all\' was clicked', js: true do
    visit root_path
    page.find('.show-categories').click
    sleep(1)
    page.must_have_content('All')
    page.must_have_content('Playground')
    click_on('All')
    sleep(1)
    page.find('.show-places').click
    sleep(1)
    screenshot_and_open_image
    page.must_have_content('Magda')
  end

  scenario 'Place is not shown when other category was clicked', js: true do
    visit root_path
    page.find('.show-categories').click
    sleep(1)
    click_on('Playground')
    sleep(1)
    page.find('.show-places').click
    sleep(1)
    page.wont_have_content('Magda')
  end

end
