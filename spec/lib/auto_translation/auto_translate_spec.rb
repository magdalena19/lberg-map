require 'auto_translation/auto_translate'
require 'auto_translation/auto_translation_gateway'
require 'auto_translation/translation_engines/google_translator_wrapper'

describe AutoTranslate do
  context 'Translate attributes' do
    it 'New place has auto_translation feature' do
      place = build :place, :unreviewed
      expect(place).to respond_to(:auto_translate_empty_attributes)
    end

    it 'Translates using correct translation engine wrapper' do
      settings = create :settings, translation_engine: 'google', auto_translate: true
      expect(settings.translation_engine).to eq('google')

      Sidekiq::Testing.inline! do
        p = create :place, :unreviewed
        expect(p.reload.description_de).to eq 'auto_translation: test_stub (GoogleTranslatorWrapper)'
      end
    end
  end
end
