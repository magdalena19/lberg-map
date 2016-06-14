require_relative '../test_helper'
require 'auto_translator'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @valid_translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    @place = Place.new(latitude: 12.0,
                       longitude: 52.0,
                       name: 'Kiezspinne',
                       street: 'Schulze-Boysen-Straße',
                       house_number: '13',
                       postal_code: '10365',
                       city: 'Berlin',
                       description_en: 'This is a test')
  end

  # AUTO TRANSLATION WRAPPER TESTS
  test 'can translate if valid credentials given' do
    assert_not_nil @valid_translator.bing_translator
  end

  test 'cannot translate if API id and key invalid or no microsoft account key' do
    invalid_translator = BingTranslatorWrapper.new(ENV['wrong_id'], ENV['wrong_secret'], ENV['microsoft_account_key'])
    assert_nil invalid_translator.bing_translator

    invalid_translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['wrong_microsoft_account_key'])
    assert_equal '', invalid_translator.failsafe_translate('Dies ist ein Test', 'en', 'de')
  end

  test "return '' if too many characters to translate" do
    text = '13 characters' * 1000
    assert_equal '', @valid_translator.failsafe_translate(text, 'en', 'de')
  end

  test 'should translate text below character limit' do
    text = 'This is a test'
    assert_equal 'Automatische Übersetzung: Dies ist ein Test', @valid_translator.failsafe_translate(text, 'en', 'de')
  end

  test 'should autotranslate after_create' do
    @place.save
    @place.reload
    assert_equal "Automatische Übersetzung: Dies ist ein Test", @place.description_de
  end
end
