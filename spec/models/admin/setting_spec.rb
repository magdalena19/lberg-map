require 'rails_helper'

RSpec.describe Admin::Setting, type: :model do
  context 'Attributes' do
    subject { build :settings }

    it { is_expected.to respond_to :admin_email_address}
    it { is_expected.to respond_to :app_title }
  end
end
