require 'rails_helper'

RSpec.describe Map, type: :model do
  context 'Attributes' do
    it { is_expected.to respond_to :title }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :imprint }
    it { is_expected.to respond_to :public }
    it { is_expected.to respond_to :public_token }
    it { is_expected.to respond_to :secret_token }
  end

  context 'Associations' do
    it { is_expected.to have_many :places }
  end
end
