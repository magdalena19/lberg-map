require 'rails_helper'

RSpec.describe MapsController, type: :controller do

  describe "GET #show" do
    before do
      @map = create :map, :full_public
      create_list(:place, 3, :reviewed, map: @map)
    end

    it "returns http success" do
      get :show, map_token: @map.public_token
      expect(response).to have_http_status(:success)
    end

    it "returns ajax success" do
      xhr :get, :show, map_token: @map.public_token
    end
  end

end
