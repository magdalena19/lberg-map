describe Category do
  context 'Associations' do
    it { is_expected.to belong_to :map }
    it { is_expected.to have_many :places }
  end

  context 'Validations' do
    before do
      @map = create :map, :full_public
    end

    it 'cannot create new translation if all translations empty' do
      @category = build :category, name_en: '', name_de: '', map: @map

      expect(@category).not_to be_valid
    end
  end
end
