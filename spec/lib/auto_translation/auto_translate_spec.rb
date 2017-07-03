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

  context 'Translation engine status' do
    before do
      mock_bing_api_keys
      mock_yandex_api_keys
      mock_google_api_keys
    end

    it 'Can query Setting class for list of working translation engines' do
      expect(Admin::Setting.working_translation_engines).to eq ["none", "google", "bing", "yandex"]
    end

    it 'Returns bing as working translation engines if API keys supplied' do
      expect(AutoTranslate::Helpers.translation_engine_working?(engine: 'bing')).to be true
    end

    it 'Returns google as working translation engines if API keys supplied' do
      expect(AutoTranslate::Helpers.translation_engine_working?(engine: 'google')).to be true
    end

    it 'Returns yandex as working translation engines if API keys supplied' do
      expect(AutoTranslate::Helpers.translation_engine_working?(engine: 'yandex')).to be true
    end
  end
end
