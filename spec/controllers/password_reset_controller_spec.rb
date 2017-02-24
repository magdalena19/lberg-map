describe PasswordResetController do
  before do
    create :settings, :public
  end

  context 'GET #request_password_reset' do
    it 'can request new password' do
      get :request_password_reset
      expect(response).to render_template 'password_reset/request_password_reset'
    end
  end

  context 'POST #create_password_reset' do
    it 'creates new password reset digest for existing account' do
      user = create :user, email: 'norbert@example.com'
      expect {
        post :create_password_reset, password_reset: { email: 'norbert@example.com' }
      }.to change { user.reload.password_reset_digest }.from(nil).to be_a(String)
    end

    it 'sends password request email on password reset request for existing account' do
      create :user, name: 'Birte', email: 'birte@example.com'
      expect {
        post :create_password_reset, password_reset: { email: 'birte@example.com' }
      }.to change { DeliveryGul.deliveries.count }.by(1)
    end

    it 'does nothing if no account was found to reset password for' do
      post :create_password_reset, password_reset: { email: 'unknown@nowhere.com' }
      expect(response).to redirect_to root_path
      expect(flash[:danger]).not_to be_nil
    end
  end

  context 'GET #reset_password' do
    let (:user) { create :user, name: 'Norber', email: 'norbert@example.com' }

    it 'allows password reset for valid token' do
      user.create_digest_for(attribute: 'password_reset')
      user.save

      get :reset_password, id: user.id, token: user.password_reset_token
      expect(response).to render_template 'password_reset/password_reset_form'
    end

    it 'alerts and redirect to root url if link is invalid' do
      user.create_digest_for(attribute: 'password_reset')
      user.save

      get :reset_password, id: user.id, token: 'Some invalid token'
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to eq('Link zum Passwort zurücksetzen ist ungültig!')
    end

    it 'does not accept tokens older than 24hrs as valid' do
      user.create_digest_for(attribute: 'password_reset')
      user.password_reset_timestamp = Time.now - 25.hours
      user.save

      get :reset_password, id: user.id, token: user.password_reset_token
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to eq('Link zum Passwort zurücksetzen ist ungültig!')
    end
  end
end
