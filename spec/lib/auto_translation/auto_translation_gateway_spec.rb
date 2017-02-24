require 'auto_translation/auto_translation_gateway'
require 'auto_translation/translation_engines/bing_translator_wrapper'
require 'auto_translation/translation_engines/yandex_translator_wrapper'
require 'auto_translation/translation_engines/google_translator_wrapper'
require 'auto_translation/translation_engines/null_translator'

describe AutoTranslationGateway do
  it 'defaults to NullTranslator if translation engine unknown' do
    settings = create :settings, translation_engine: 'SomeUnknownEngine'
    expect(AutoTranslationGateway.new.engine).to eq(NullTranslator)
  end

  it 'defaults to NullTranslator if translation engine empty' do
    settings = create :settings, translation_engine: ''
    expect(AutoTranslationGateway.new.engine).to eq(NullTranslator)
  end

  it 'sets correct translation engine' do
    settings = create :settings, translation_engine: 'bing'
    expect(AutoTranslationGateway.new.engine).to eq(BingTranslatorWrapper)

    settings.update(translation_engine: 'yandex')
    expect(AutoTranslationGateway.new.engine).to eq(YandexTranslatorWrapper)

    settings.update(translation_engine: 'google')
    expect(AutoTranslationGateway.new.engine).to eq(GoogleTranslatorWrapper)
  end
end
