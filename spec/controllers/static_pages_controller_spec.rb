require 'rails_helper'

describe StaticPagesController do
  context 'GET #about' do
    it 'should render about template' do
      get :about
      expect(response).to render_template 'static_pages/about'
    end
  end

  context 'GET #map' do
    it 'does respond with places in session' do
      @request.cookies[:created_places_in_session] = [1, 2, 3, 4, 5, 7723487]
      get :map
      expect(response).to render_template 'static_pages/map'
    end
  end
end
