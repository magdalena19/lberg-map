feature 'Index', :js do
  before do
    @map = create :map, :full_public
    create :place, :reviewed, name: 'Haus vom Nikolaus', phone: 1234, categories_string: 'Playground', map: @map
    create :place, :reviewed, name: 'Katzenklo', categories_string: 'Lawyer', map: @map
  end

  scenario 'shows places in datatable' do
    skip 'DEPRECATED: Map index no longer existent...'
    show_places_index(map_token: @map.public_token)

    expect(page).to have_content('Katzenklo')
    expect(page).to have_content('Haus vom Nikolaus')
    expect(page).to_not have_content('1234')
    all('.place_type_col').first.click()
    expect(page).to have_content('1234')
  end

  scenario 'has working delete buttons' do
    skip 'DEPRECATED: Map index no longer existent...'
    login_as_user
    show_places_index(map_token: @map.public_token)
    all('.place_type_col').first.click
    all('.glyphicon-trash').first.click

    expect(page).to have_content('Katzenklo')
    expect(page).to_not have_content('Haus vom Nikolaus')
    expect(page).to have_content('Place deleted')
  end
end
