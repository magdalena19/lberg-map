require 'rails_helper'

describe UsersController do
	let(:user) { create :user, name: 'Norbert' }

  before do
    create :settings
  end

  context 'GET #edit' do
    it 'should populate user' do
      login_as user
      get :edit, id: user.id
      expect(assigns(:user)).to eq(user)
    end

    it 'should render :edit template' do
      login_as user
      expect(

        get :edit, id: user.id
      ).to render_template :edit
    end

    context 'reject editing' do
      it 'if not logged in' do
        get :edit, id: user.id

        expect(response).to redirect_to login_path
      end

      it 'other groups users' do
        login_as user
        other_user = create :user, name: 'Susanne'
        get :edit, id: other_user.id

        expect(response).to redirect_to root_path
      end
    end
  end

  context 'GET #sign_up' do
    before do
      get :sign_up
    end

    it 'renders template :sign_up' do
      expect(response).to render_template :sign_up
    end

    it 'populates new user in @user' do
      expect(assigns(:user)).to be_a(User)
    end
  end

  context 'POST #create' do
    context 'accept request' do
      before do
        @user = create :user
        @token = @user.activation_tokens.first.token
        post :create, user: attributes_for(:user, password: 'secret', password_confirmation: 'secret'), activation_token: @token
      end

      it 'sends welcome email' do
        Sidekiq::Testing.inline! do
          expect{
            post :create, user: attributes_for(:user, password: 'secret', password_confirmation: 'secret'), activation_token: @token
          }.to change{ DeliveryGul.deliveries.count }.by(1)
        end
      end

      it 'creates new valid user if activation_token valid' do
        expect(User.count).to be 2
      end

      it 'invalidates a token on user create' do
        @user.reload
        expect(@user.activation_tokens.first.redeemed).to be true
      end

      it 'redirects to map index after creating new user' do
        expect(response).to redirect_to maps_path
      end
    end

    context 'reject request' do
      it 'if activation token not valid' do
        users = create_list :user, 3
        post :create, user: attributes_for(:user, password: 'secret', password_confirmation: 'secret'), activation_token: 'SomeInvalidToken'
        expect(response).to have_http_status(403)
        expect(response).to render_template :sign_up
      end
    end
  end

  context 'PATCH #update' do
    it 'should update if attributes are valid' do
      login_as user
      put :update, id: user.id, user: {
        name: 'SomeOtherName',
        email: 'foo@bar.batz',
        password: 'schnipp',
        password_confirmation: 'schnipp' }

      user.reload do |user|
        expect(user.email).to eq('foo@bar.batz')
        expect(user.name).to eq('SomeOtherName')
      end
    end

    context 'reject updates' do
      it 'if not logged in' do
        patch :update, id: user.id, user: { name: 'SomeOtherName' }

        expect(response).to redirect_to login_path
        expect(user.reload.name).not_to eq('SomeOtherName')
      end

      it 'on other users' do
        login_as user
        other_user = create :user
        patch :update, id: other_user.id, user: { name: 'SomeOtherName' }

        expect(response).to redirect_to root_path
        expect(other_user.reload.name).not_to eq('SomeOtherName')
      end
    end
  end
end
