require 'auto_translation/auto_translate'
require 'auto_translation/auto_translation_gateway'
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

    it 'Translates using correct translation engine wrapper' do
      settings = create :settings, translation_engine: 'google', auto_translate: true

      Sidekiq::Testing.inline! do
        p = create :place, :unreviewed
        expect(settings.translation_engine).to eq('google')
        expect(p.reload.description_de).to eq 'stubbed autotranslation'
      end
    end
  end
end
