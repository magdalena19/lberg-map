require 'auto_translation/auto_translate'

class Category < ActiveRecord::Base
  include AutoTranslate

  belongs_to :map

  translates :name
  globalize_accessors

  before_create :prepare_for_autotranslation
  after_create :enqueue_auto_translation, if: 'map.auto_translate'

  def enqueue_auto_translation
    TranslationWorker.perform_async('Category', id, map.supported_languages)
  end

  # Set all name columns to empty in order to create translation records on create
  def prepare_for_autotranslation
    I18n.available_locales.each do |locale|
      next if send("name_#{locale}").present?
      send("name_#{locale}=", '')
    end
  end
end
