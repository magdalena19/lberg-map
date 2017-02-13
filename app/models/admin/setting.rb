class Admin::Setting < ActiveRecord::Base
  def self.all_settings
    spawn_default_settings unless self.any?
    self.last.attributes.except("id")
  end

  def self.maintainer_email_address
    spawn_default_settings unless self.any?
    self.last.maintainer_email_address
  end

  def self.app_title
    spawn_default_settings unless self.any?
    self.last.app_title
  end

  def self.is_private
    spawn_default_settings unless self.any?
    self.last.is_private
  end

  def self.auto_translate
    spawn_default_settings unless self.any?
    self.last.auto_translate
  end

  private

  def self.spawn_default_settings
    # spawns defaults defined in schema
    self.create
  end
end
