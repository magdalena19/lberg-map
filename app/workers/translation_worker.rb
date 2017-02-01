class TranslationWorker
  include Sidekiq::Worker

  def perform(classname, id)
    klass = classname.singularize.constantize
    obj = klass.find(id)
    obj.auto_translate_empty_attributes
  end
end
