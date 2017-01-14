require_relative '../test_helper'

class AutoTranslatorTest < ActiveSupport::TestCase
  # def setup
  #   @valid_translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
  # end

  # AUTO TRANSLATION WRAPPER TESTS
  test 'can translate if valid credentials given' do
    skip('Problems with API init')
    assert_not_nil @valid_translator.bing_translator
  end

  test 'cannot translate if API id and key invalid or no microsoft account key' do
    skip('Problems with API init')
    invalid_translator = BingTranslatorWrapper.new(ENV['wrong_id'], ENV['wrong_secret'], ENV['microsoft_account_key'])
    assert_nil invalid_translator.bing_translator

    invalid_translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['wrong_microsoft_account_key'])
    assert_equal '', invalid_translator.failsafe_translate('Dies ist ein Test', 'en', 'de')
  end

  test "return '' if too many characters to translate" do
    skip('Problems with API init')
    text = '13 characters' * 1000
    assert_equal '', @valid_translator.failsafe_translate(text, 'en', 'de')
  end

  test 'should translate text below character limit' do
    skip('Problems with API init')
    text = 'This is a test'
    assert_equal 'Dies ist ein Test', @valid_translator.failsafe_translate(text, 'en', 'de')
  end
end
