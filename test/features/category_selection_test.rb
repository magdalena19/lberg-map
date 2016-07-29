require 'test_helper'

feature 'Category selection' do
  before do
    @place = Place.new(
      name: 'Magda',
      street: 'Magdalenenstraße',
      house_number: '19',
      postal_code: '10365',
      city: 'Berlin',
      description_en: '<center><b>This is the description.</b></center>',
      latitude: 13,
      longitude: 52,
      reviewed: true
    )
    @place.save
    @category = Category.new(name_en: 'Playground', name_de: 'Spielplatz', name_fr: 'Spielplatz', name_ar: 'Spielplatz')
    @category.save
    Category.new(name_en: 'Hospital', name_de: 'Krankenhaus', name_fr: 'Krankenhaus', name_ar: 'Krankenhaus').save
    Categorizing.new(place_id: @place.id, category_id: @category.id).save
  end

  scenario 'Place is shown when \'all\' was clicked', js: true do
    show_category_panel
    page.must_have_content('All')
    page.must_have_content('Playground')
    click_on('All')
    sleep(1)
    page.find('.show-places').trigger('click')
    sleep(1)

    page.must_have_content('Magda')
  end

  scenario 'Place is shown when right category was clicked', js: true do
    show_category_panel
    click_on('Playground')
    sleep(1)
    page.find('.show-places').trigger('click')
    sleep(1)
    page.must_have_content('Magda')
  end

  scenario 'Place is not shown when other category was clicked', js: true do
    show_category_panel
    click_on('Hospital')
    sleep(1)
    page.find('.show-places').trigger('click')
    sleep(1)
    page.wont_have_content('Magda')
  end

  def show_category_panel
    visit root_path
    page.click_on('language')
    page.find('.show-categories').trigger('click')
    sleep(1)
  end

end
