require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  before do
    login_as create(:user, :admin)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'populates all registered user in @users' do
      users = create_list(:user, 3)
      get :index
      expect(assigns(:users)).to eq(User.all)
    end

    context 'rejects index' do
      it 'without admin privileges' do
        login_as create(:user)
        get :index
        expect(response).to redirect_to root_url
        expect(assigns(:users)).to be_nil
      end
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'instantiates new user in @user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    context 'rejects access' do
      it 'without admin privileges' do
        login_as create(:user)
        get :new
        expect(response).to redirect_to root_url
        expect(assigns(:users)).to be_nil
      end
    end
  end

  describe 'POST #create' do
    it 'creates new valid user' do
      expect {
        post :create, user: attributes_for(:user, password: 'secret', password_confirmation: 'secret')
      }.to change { User.count }.by(1)
    end

    it 'redirects to users index after creating new user' do
      post :create, user: attributes_for(:user, password: 'secret', password_confirmation: 'secret')
      expect(response).to redirect_to admin_users_url
    end

    it 'renders :new template if input invalid' do
      post :create, user: { name: '', email: '', password: 'secret', password_confirmation: 'secret' }
      expect(response).to render_template :new
      expect(flash[:danger]).to match /blank/
    end

    context 'rejects creating new user' do
      it 'without admin privileges' do
        login_as create(:user)
        expect {
          post :create, user: { name: '', email: '', password: 'secret', password_confirmation: 'secret' }
        }.to change { User.count }.by(0)
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'GET #edit' do
    let(:users) { create_list(:user, 3) }

    it 'populates right user in @user' do
      get :edit, id: users.first.id
      expect(assigns(:user)).to eq users.first
    end

    it 'renders edit template' do
      get :edit, id: users.first.id
      expect(response).to render_template :edit
    end

    context 'rejects access' do
      it 'without admin privileges' do
        users = create_list(:user, 3)
        login_as users.first
        get :edit, id: users.first.id
        expect(assigns(:user)).to be_nil
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'PATCH #update' do
    let(:users) { create_list(:user, 3) }

    it 'updates user' do
      patch :update, id: users.first.id, user: { name: 'SomeOtherName' }
      expect(users.first.reload.name).to eq('SomeOtherName')
    end

    it 'redirects to users index after updating' do
      patch :update, id: users.first.id, user: { name: 'SomeOtherName' }
      expect(response).to redirect_to admin_users_url
    end

    it 'renders edit template if invalid input' do
      patch :update, id: users.first.id, user: { name: '' }
      expect(response).to render_template :edit
      expect(flash[:danger]).to match 'blank'
    end

    context 'rejects updating user' do
      it 'without admin privileges' do
        users = create_list(:user, 3)
        login_as users.first
        patch :update, id: users.last.id, user: { name: 'SomeOtherName' }
        expect(users.last.reload.name).not_to eq('SomeOtherName')
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:users) { create_list(:user, 3) }

    it 'deletes users' do
      users = create_list(:user, 3) 
      login_as create(:user, :admin)
      expect {
        delete :destroy, id: users.first.id
      }.to change { User.count }.by(-1)
    end

    it 'redirects to users index after deletion' do
      login_as create(:user, :admin)
      delete :destroy, id: users.first.id
      expect(response).to redirect_to admin_users_url
    end

    context 'rejects deleting' do
      let(:users) { create_list(:user, 2) }

      it 'rejects deleting user if is current user' do
        admin = create :user, :admin
        login_as admin
        delete :destroy, id: admin.id
        expect(response).to redirect_to admin_users_url
        expect(flash[:danger]).to match /cannot delete/
      end

      it 'rejects deleting if not admin user' do
        login_as users.first
        expect {
          delete :destroy, id: users.last.id
        }.to change { User.count }.by(0)
        expect(response).to redirect_to root_url
      end
    end
  end
end
