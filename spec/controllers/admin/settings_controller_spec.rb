require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :controller do

  describe "GET #edit" do
    before do
      login_as create(:user, :admin)
    end

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
        login_as create(:user)
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

  describe 'PUT #update' do
    let(:settings) { create :settings, :top_secret }

    it 'can update settings' do
      login_as create(:user, :admin)
      put :update, id: settings.id, admin_setting: { auto_translate: false }
      expect(Admin::Setting.auto_translate).to be false
    end

    it 'redirects to settings path and renders :edit template' do
      login_as create(:user, :admin)
      put :update, id: settings.id, admin_setting: { auto_translate: false }
      expect(response).to redirect_to admin_settings_url

    end
  end

  context 'rejects update' do
    let(:settings) { create :settings, :top_secret }

    it 'if not admin and redirects to root path' do
      login_as create(:user)
      put :update, id: settings.id, admin_setting: { auto_translate: true}
      expect(Admin::Setting.auto_translate).to be false
      expect(response).to redirect_to root_url
    end

    it 'if guest user and redirects to root path' do
      put :update, id: settings.id, admin_setting: { auto_translate: true}
      expect(Admin::Setting.auto_translate).to be false
      expect(response).to redirect_to root_url
    end
  end
end
