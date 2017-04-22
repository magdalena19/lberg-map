require 'auto_translation/auto_translate'

describe Category do
  context 'Associations' do
    it { is_expected.to belong_to :map }
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
