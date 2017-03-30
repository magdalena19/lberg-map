require 'rails_helper'

RSpec.describe Admin::Setting, type: :model do
  context 'Attributes' do
    subject { build :settings }

    it { is_expected.to respond_to :admin_email_address}
    it { is_expected.to respond_to :app_title }
    it { is_expected.to respond_to :user_activation_tokens }
  end

  context 'Activation tokens' do
    it 'defaults to 2' do
      expect(Admin::Setting.create.user_activation_tokens).to be 2
    end

    it 'does not except invalid number of activation tokens' do
      settings = build :settings, user_activation_tokens: -1
      expect(settings).not_to be_valid
    end
  end
end
