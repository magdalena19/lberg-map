require_relative '../test_helper'

class PlaceTest < ActiveSupport::TestCase
  include Place::AutoTranslator

  def setup
    @place = Place.new(latitude: 12.0,
                       longitude: 52.0,
                       name: 'Kiezspinne',
                       street: 'Schulze-Boysen-Straße',
                       house_number: '13',
                       postal_code: '10365',
                       city: 'Berlin',
                       description_en: 'This is a test')
  end

  test 'valid place is valid' do
    assert @place.valid?
  end

  test 'empty Place object should not be valid' do
    assert_not Place.new.valid?
  end

  test 'name should not be blank' do
    @place.name = ''
    assert_not @place.valid?
  end

  # test 'html should be sanitized' do
  #   @place.description_en = '<center><b>This is the description.</b></center>'
  #   @place.save
  #   saved_description = Place.find_by(name: 'Kiezspinne').description_en
  #   assert_equal(saved_description, '<b>This is the description.</b>')
  # end

  # AUTO TRANSLATION WRAPPER TESTS
  test 'should autotranslate after_create' do
    @place.save
    @place.reload
    assert_equal "Automatische Übersetzung: Dies ist ein Test", @place.description_de
  end

  # The following tests might fail if no valid BING credentials are supplied
  test 'can translate if valid credentials given' do
    translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    assert_not_nil translator.bing_translator
  end

  test 'cannot translate if API id and key invalid' do
    translator = BingTranslatorWrapper.new(ENV['wrong_id'], ENV['wrong_secret'], ENV['microsoft_account_key'])
    assert_nil translator.bing_translator
  end

  test "return '' if too many characters to translate" do
    translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    text = '13 characters' * 1000
    assert_equal '', translator.failsafe_translate(text, 'en', 'de')
  end

  test 'should translate text below character limit' do
    translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    text = 'This is a test'
    assert_equal 'Dies ist ein Test', translator.failsafe_translate(text, 'en', 'de')
  end

  # TODO: Check whether entry is already in DB
  test 'duplicate entries not valid' do
  end
end
