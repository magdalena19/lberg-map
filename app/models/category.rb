require 'auto_translation/auto_translate'

class Category < ActiveRecord::Base
  include AutoTranslate

  translates :name
  globalize_accessors

  before_create :prepare_for_autotranslation
  after_create :enqueue_auto_translation

  def enqueue_auto_translation
    TranslationWorker.perform_async('Category', id) if Admin::Setting.auto_translate
  end

  # Set all name columns to empty in order to create translation records on create
  def prepare_for_autotranslation
    I18n.available_locales.each do |locale|
      next if send("name_#{locale}").present?
      send("name_#{locale}=", '') 
    end
  end

  def self.id_for(category_string)
    category = Category.all.find do |cat|
      category_string.tr('_', ' ').casecmp(cat.name).zero?
    end
    category.id if category
  end
end
