# Wrapper for bing translation engine
class BingTranslatorWrapper
  attr_reader :bing_translator

  def initialize
    id = ENV['bing_id']
    secret = ENV['bing_secret']
    account_key = ENV['microsoft_account_key']

    @bing_translator = BingTranslator.new(id, secret, false, account_key)
  end

  def translate(text:, from:, to:)
    translation = @bing_translator.translate(text, from: from.to_s, to: to.to_s)
  end

  def char_balance_sufficient?
    char_balance_sufficient = @bing_translator.balance >= text.length
  rescue
    false
  else
    char_balance_sufficient 
  end

  def languages_available?(lang_codes)
    languages_available = @bing_translator.supported_language_codes
    matches = lang_codes.each do |language|
      languages_available.include?(language)
    end
  rescue
    false
  else
    matches.all?
  end
end
