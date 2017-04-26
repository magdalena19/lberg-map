class TranslationWorker
  include Sidekiq::Worker

  def perform(classname, id, supported_languages)
    klass = classname.singularize.constantize
    obj = klass.find(id)
    obj.auto_translate_empty_attributes(supported_languages: supported_languages)
  end
end
