require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :controller do
  before do
    login_as create(:user, :admin, email: 'batz@bar.org')
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit

      expect(response).to have_http_status(:success)
    end

    it 'populates settings' do
      settings = Admin::Setting.create!()
      get :edit

      expect(assigns(:settings)).to eq(settings)
      expect(assigns(:settings_hash)).to be_a(Hash)
    end

    it 'renders edit template' do
      get :edit
      expect(response).to render_template :edit
    end

    context 'rejects access' do
      it 'if not admin' do
        login_as create(:user, email: 'foo@bar.org')
        get :edit

        expect(response).to redirect_to root_path
      end

      it 'if guest user' do
        logout
        get :edit

        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #captcha-status' do
    context 'simple captcha' do
      it 'reports working for simple_captcha' do
        xhr :get, :captcha_system_status, captcha_system: 'simple_captcha' 

        expected_response = {status_code: 'working', status_message: 'Captcha system working'}.to_json
        expect(response.body).to eq expected_response
      end
    end
  end

  describe 'PATCH #update' do
    it 'updates default POI color' do
      patch :update, admin_setting: { default_poi_color: 'purple' }

      expect(Admin::Setting.default_poi_color).to eq 'purple'
    end

    it 'updates multi color poi flag' do
      patch :update, admin_setting: { multi_color_pois: false}

      expect(Admin::Setting.multi_color_pois).to eq false
    end

    context 'rejects update' do
    end
  end
end
