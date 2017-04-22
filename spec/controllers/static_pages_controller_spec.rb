require 'rails_helper'

describe StaticPagesController do
  context 'GET #landing_page' do
    it 'redirects to map index if signed in' do
      login_as create :user
      get :landing_page
      expect(response).to redirect_to maps_path
    end
  end
end
