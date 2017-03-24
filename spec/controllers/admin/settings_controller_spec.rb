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
  end

  context 'rejects update' do
  end
end
