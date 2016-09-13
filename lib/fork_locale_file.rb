require 'fileutils'
require 'yaml'

module ForkLocaleFile
  def self.empty_all_values(hash)
    hash.each do |key, value|
      if value.class == Hash
        empty_all_values(value)
      else
        hash[key] = ''
      end
    end
  end

  def self.substitue_language_key(hash, target_lang)
    { target_lang => hash[hash.keys.first] }
  end

  def self.fork_locale_file(pattern, to, filepath)
    orig_locale_hash = YAML.load(File.open(filepath, 'r'))
    empty_locale_hash = empty_all_values(orig_locale_hash)
    to.each do |locale|
      new_filename = filepath.gsub pattern, locale + '_'
      next if File.exist?(new_filename)
      target_locale_hash = substitue_language_key(empty_locale_hash, locale)
      File.open(new_filename, 'w') { |f| f.write target_locale_hash.to_yaml }
    end
  end

  def self.browse_and_fork(path, pattern, new_locales = nil)
    items = Dir.entries(path).select { |e| !e.start_with?('.') }
    items.each do |item|
      full_path = path + '/' + item
      if File.directory?(full_path)
        browse_and_fork(full_path, pattern, new_locales)
      elsif item.match pattern
        fork_locale_file(pattern, new_locales, full_path)
      end
    end
  end

  def self.fork(from:, to:)
    path = Rails.root.to_s + '/config/locales/'
    begin
      if to && from
        pattern = from.match(/_/) ? from : from.to_s + '_'
        browse_and_fork(path, pattern, to)
        p 'Files created. Do not forget to add locales to available_locales array in config/application.rb!'
      else
        p 'Please specify original and target languages to create files from and for!'
      end
    rescue => e
      p e
    end
  end
end
