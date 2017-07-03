require 'auto_translation/auto_translate'

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

  context 'Auto-translation' do
    before do
      @map = create :map, :full_public
    end

    it 'can auto translate category names' do
      category = @map.categories.create name: 'NewCategory'
      expect(category).to respond_to(:auto_translate_empty_attributes)
    end

    it 'auto translates blank category names' do
      category = @map.categories.new name: 'NewCategory', name_de: ''

      expect(category.name_de).to eq('')
      Sidekiq::Testing.inline! do
        category.save
        expect(category.reload.name_de).to eq('stubbed autotranslation')
      end
    end
  end
end
