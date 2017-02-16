require 'auto_translation/auto_translation_gateway'
require 'auto_translation/translation_engines/bing_translator_wrapper'
require 'auto_translation/translation_engines/yandex_translator_wrapper'
require 'auto_translation/translation_engines/google_translator_wrapper'
require 'auto_translation/translation_engines/null_translator'

describe AutoTranslationGateway do
  it 'defaults to NullTranslator if no engine as parameter' do
    expect(AutoTranslationGateway.new.translator).to be_a(NullTranslator)
  end
  
  it 'defaults to NullTranslator if translation engine unknown' do
    expect(AutoTranslationGateway.new(engine: 'SomeUnknownEngine').translator).to be_a(NullTranslator)
  end

  it 'wraps correct translation engine' do
    expect(AutoTranslationGateway.new(engine: 'bing').translator).to be_a(BingTranslatorWrapper)
    expect(AutoTranslationGateway.new(engine: 'yandex').translator).to be_a(YandexTranslatorWrapper)
    expect(AutoTranslationGateway.new(engine: 'google').translator).to be_a(GoogleTranslatorWrapper)
  end
end
