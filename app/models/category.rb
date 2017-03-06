require 'auto_translation/auto_translate'

class Category < ActiveRecord::Base
  include AutoTranslate

  translates :name
  globalize_accessors

  after_create :enqueue_auto_translation

  def enqueue_auto_translation
    TranslationWorker.perform_async('Category', id) if Admin::Setting.auto_translate
  end

  def self.id_for(category_string)
    category = Category.all.find do |cat|
      category_string.tr('_', ' ').casecmp(cat.name).zero?
    end
    category.id if category
  end
end
