feature 'Image upload', :js do
  before do
    @map = create :map, :full_public
    @place = create :place, map: @map, name: 'Foo'
  end

  scenario 'can upload images' do
    visit map_path(map_token: @map.secret_token)
    add_place_manually
    fill_in_valid_place_information(name: 'Place with image')

    upload_two_images
    expect(page).to have_css("img[src*='cat.png']")
    expect(page).to have_css("img[src*='feminism.png']")

    change_one_image
    expect(page).to have_css("img[src*='dog.png']")
    expect(page).to have_css("img[src*='feminism.png']")

    destroy_one_image
    expect(page).to have_css("img[src*='dog.png']")
    expect(page).to_not have_css("img[src*='feminism.png']")
  end

  private

  def destroy_one_image
    edit_place_modal
    find_all('.destroy-image').first.trigger('click')
    find('.submit-place-button').trigger('click')
    expect(page).to have_content('Changes saved')
    find('.leaflet-marker-icon').trigger('click')
  end

  def change_one_image
    edit_place_modal
    upload_file(0, 'dog.png')
    find('.submit-place-button').trigger('click')
    expect(page).to have_content('Changes saved')
    find('.leaflet-marker-icon').trigger('click')
  end

  def upload_two_images
    upload_file(0, 'cat.png')
    upload_file(1, 'feminism.png')
    find('.submit-place-button').trigger('click')
    find('.leaflet-marker-icon').trigger('click')
  end

  def edit_place_modal
    sleep 0.5
    find('.edit-place').trigger('click')
    sleep 0.5
  end

  def upload_file(image_number, file_name)
    page.attach_file(
      "place_place_attachments_attributes_#{image_number}_image",
      File.join(Rails.root + "spec/support/images/#{file_name}")
    ).click
  end
end
