require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :controller do

  describe "GET #index" do
    before do
      login_as create(:user, :admin)
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'populates settings in @settings' do
      settings = Admin::Setting.create!()
      get :index
      expect(assigns(:settings)).to eq([ settings ])
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template :index
    end

    context 'rejects access' do
      it 'if not admin' do
        login_as create(:user)
        get :index
        expect(response).to redirect_to root_path
      end

      it 'if guest user' do
        logout
        get :index
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'Cannot POST and DELETE' do
    before do
      login_as create(:user, :admin)
    end

    it 'rejects post' do
      expect {
        post :create, settings: {}
      }.to raise_error(ActionController::UrlGenerationError)
    end
  end
  
  it 'rejects deleting settings' do
    settings = Admin::Setting.create()
    expect {
      delete :destroy, id: settings.id
    }.to raise_error(ActionController::UrlGenerationError)
  end
end
