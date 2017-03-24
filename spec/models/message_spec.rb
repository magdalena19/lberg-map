describe Message do
  context 'Associations' do
    it { is_expected.to belong_to :map }
  end
end
