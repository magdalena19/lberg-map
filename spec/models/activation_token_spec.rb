require 'rails_helper'

RSpec.describe ActivationToken, type: :model do
  context 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  context 'Attributes' do
    before do
      @token = ActivationToken.create
    end

    it 'Sets random token on create' do
      expect(@token.token).to be_a(String) 
      expect(@token.token.length).to be 16
    end

    it 'Can invalidate itself' do
      @token.invalidate

      expect(@token.redeemed).to be true
    end
  end
end
