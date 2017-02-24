feature 'Index' do
  before do
    create :settings, :public
    spawn_categories
    create :settings
    create(:place, :reviewed, name: 'Haus vom Nikolaus', phone: 1234, categories: '1,2')
    create(:place, :reviewed, name: 'Katzenklo', categories: '3')
  end

  scenario 'shows places in datatable', js: true do
    visit places_path

    expect(page).to have_content('Katzenklo')
    expect(page).to have_content('Haus vom Nikolaus')
    expect(page).to_not have_content('1234')
    all('.triangle').first.click()
    expect(page).to have_content('1234')
  end

  scenario 'has working category button', js: true do
    visit places_path

    find('.btn', text: 'Playground').trigger('click')
    expect(page).to_not have_content('Katzenklo')
    expect(page).to have_content('Haus vom Nikolaus')
  end

  scenario 'has working delete buttons', js: true do
    login_as_user
    visit places_path

    all('.glyphicon-trash').first.click
    expect(page).to have_content('Katzenklo')
    expect(page).to_not have_content('Haus vom Nikolaus')
    expect(page).to have_content('Place deleted')
  end
end
