require 'rails_helper'

RSpec.describe Admin::Setting, type: :model do
  context 'Attributes' do
    subject { build :settings }

    it { is_expected.to respond_to :admin_email_address}
    it { is_expected.to respond_to :app_title }
    it { is_expected.to respond_to :app_imprint }
    it { is_expected.to respond_to :app_privacy_policy }
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

  context 'Callbacks' do
    it 'should sanitize app imprint before validation' do
      settings = create :settings, app_imprint: '<center>This is an imprint</center>'
      expect(settings.app_imprint).to eq 'This is an imprint'
    end

    it 'should sanitize app privacy policy before validation' do
      settings = create :settings, app_privacy_policy: '<center>Privacy rulez!</center>'
      expect(settings.app_privacy_policy).to eq 'Privacy rulez!'
    end
  end
end
