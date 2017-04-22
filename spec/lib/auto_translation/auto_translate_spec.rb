require 'auto_translation/auto_translate'
require 'auto_translation/translation_engines/google_translator_wrapper'

describe AutoTranslate do
  before do
    stub_autotranslation
  end

  context 'Translate attributes' do
    it 'New place has auto_translation feature' do
      place = build :place, :unreviewed
      expect(place).to respond_to(:auto_translate_empty_attributes)
    end
  end
end
