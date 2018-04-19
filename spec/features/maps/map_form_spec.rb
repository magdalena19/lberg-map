feature 'Map form', js: true do
  context 'Edit map' do
    before do
      execute_script("jQuery('.footer').css('display', 'none')") # circumvent button finding prob
      @map = create :map, :full_public
      visit edit_map_path(map_token: @map.secret_token)
    end

    scenario 'it does not reassign public and secret token' do
      find_correct_secret_token
      find_correct_public_token
    end

    private

    def find_correct_secret_token
      secret_token_field_value = find('#map_secret_token').value

      expect(secret_token_field_value).to eq @map.secret_token
    end

    def find_correct_public_token
      click_on('Publication settings')
      public_token_field_value = find('#map_public_token').value

      expect(public_token_field_value).to eq @map.public_token
    end
  end
end
