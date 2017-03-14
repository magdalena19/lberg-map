require 'auto_translation/auto_translate'

describe Category do
  before do
    create :settings
  end

  it 'can auto translate category names' do
    category = Category.create name: 'NewCategory'
    expect(category).to respond_to(:auto_translate_empty_attributes)
  end

  it 'auto translates blank category names' do
    category = Category.new name_en: 'NewCategory', name_de: ''

    expect(category.name_de).to eq('')
    Sidekiq::Testing.inline! do
      category.save
      expect(category.reload.name_de).to eq('stubbed autotranslation')
    end
  end
end
