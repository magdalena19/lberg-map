class Array
  def except value
    value = value.kind_of?(Array) ? value : [value]
    self - value
  end
end

class Admin::Setting < ActiveRecord::Base
  def self.all_settings
    self.last.attributes.except("id")
  end

  # cheap...
  def self.translation_engines
    ['bing', 'google', 'yandex']
  end

  Admin::Setting.create unless Admin::Setting.any?
  # spawn default values (-> schema) if no current settings available
  column_names.except("id").each do |column_name|
    define_singleton_method(column_name.to_sym) do
      last.send(column_name)
    end
  end
end
