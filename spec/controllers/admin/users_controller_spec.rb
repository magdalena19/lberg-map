require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do

  describe "GET #index" do
    let(:users) { create_list(:user, 3) }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'populates all registered user in @users' do
      get :index
      expect(assigns(:users)).to eq users
    end
  end

  describe "GET #show" do
    let(:users) { create_list(:user, 3) }

    it "returns http success" do
      get :show, id: users.first.id
      expect(response).to have_http_status(:success)
    end

    it 'populates the right user in @user' do
      get :show, id: users.first.id
      expect(assigns(:user)).to eq users.first
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'instantiates new user in @user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST #create" do
    let(:new_user) { { name: 'TestUser', 
                              email: 'user@test.com',
                              password: 'secret',
                              password_confirmation: 'secret' } }

    it 'creates new valid user' do
      expect {
        post :create, user: new_user
      }.to change { User.count }.by(1)
    end

    it 'redirects to users index after creating new user' do
      post :create, user: new_user
      expect(response).to redirect_to admin_index_users_url
    end

    it 'renders :new template if input invalid' do
      post :create, user: { name: '', email: '', password: 'secret', password_confirmation: 'secret' }
      expect(response).to render_template :new
      expect(flash[:danger]).to match /blank/
    end
  end

  describe "GET #edit" do
    let(:users) { create_list(:user, 3) }

    it 'populates right user in @user' do
      get :edit, id: users.first.id
      expect(assigns(:user)).to eq users.first
    end

    it 'renders edit template' do
      get :edit, id: users.first.id
      expect(response).to render_template :edit
    end
  end

  describe "PATCH #update" do
    let(:users) { create_list(:user, 3) }

    it 'updates user' do
      patch :update, id: users.first.id, user: { name: 'SomeOtherName' }
      expect(users.first.reload.name).to eq('SomeOtherName')
    end

    it 'redirects to users index after updating' do
      patch :update, id: users.first.id, user: { name: 'SomeOtherName' }
      expect(response).to redirect_to admin_index_users_url
    end

    it 'renders edit template if invalid input' do
      patch :update, id: users.first.id, user: { name: '' }
      expect(response).to render_template :edit
      expect(flash[:danger]).to match 'blank'
    end
  end

  describe "GET #destroy" do
    let(:users) { create_list(:user, 3) }

    it 'deletes users' do
      users = create_list(:user, 3) 
      expect {
        delete :destroy, id: users.first.id
      }.to change { User.count }.by(-1)
    end

    it 'redirects to users index after deletion' do
      delete :destroy, id: users.first.id
      expect(response).to redirect_to admin_index_users_url
    end
  end

end
