describe User do

  context 'General attributes' do
    it 'Generates n activation tokens on create' do
      create :settings, user_activation_tokens: 2
      user = build :user
      user.save
      expect(user.activation_tokens.count).to be 2
    end
  end

  context 'Validations' do
    let(:user) { build :user }

    it 'name cannot be blank' do
      user.name = ''
      expect(user).not_to be_valid
    end

    it 'password must be longer than 5 chars' do
      user.password = 'asd'
      user.password_confirmation = 'asd'
      expect(user).not_to be_valid
    end

    it 'cannot add user with invalid email' do
      user.email = 'peokjwef@pokpwe'
      expect(user).not_to be_valid
    end

    it 'cannot add user with duplicate email address' do
      create :user, email: 'foo@bar.org'
      user.email = 'foo@bar.org'

      expect(user).not_to be_valid
    end
  end

  context 'Regular user' do
    let(:user) { build :user }

    it 'user email is not blank' do
      expect(user.email.present?).to be true
    end

    it "user is not admin" do
      expect(user.admin?).not_to be true
    end

    it "user is signed in" do
      expect(user.signed_in?).to be true
    end
  end

  context 'Admin user' do
    let(:admin) { build :user, :admin}

    it 'admin user is admin' do
      expect(admin.admin?).to be true
    end
  end

  context 'GuestUser' do
    let(:guest_user) { GuestUser.new }

    it "guest is not signed in" do
      expect(guest_user.signed_in?).to be false
    end

    it 'guest user email is blank' do
      expect(guest_user.email).to eq('')
    end

    it "guest user name is 'Guest'" do
      expect(guest_user.name).to eq('Guest')
    end

    it "guest user is not admin" do
      expect(guest_user.admin?).to be false
    end

    it "guest user is guest" do
      expect(guest_user.guest?).to be true
    end
  end

  context 'Associations' do
    it { is_expected.to have_many(:maps) }
    it { is_expected.to have_many(:activation_tokens) }

    it 'destroys associated activation tokens' do
      user = create :user
      expect{
        user.destroy }.to change{ ActivationToken.count }.from(2).to(0)
    end
  end
end

