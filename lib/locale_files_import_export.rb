require 'csv'
require 'yaml'
require 'pry'

class Array
  def empty_strings_to_nil
    self.map { |e| e == "" ? nil : e }
  end
end

class Hash
  def restructure_hash(parent = nil, h = self, tmp = {})
    h.each do |key, value|
      if value.is_a?(Hash)
        restructure_hash(key, value, tmp)
      else
        tmp[key.to_s] = value
      end
    end
    tmp
  end

  def find_and_replace_with(parent = nil, h = self, replace_elements)
    h.each do |key, value|
      if value.is_a?(Hash)
        find_and_replace_with(key, value, replace_elements)
      else
        unless h[key] = replace_elements[key]
          h[key] = '[missing translation!]'
        end
      end
    end
    h
  end

  def trim_hash_elements
    self.keys.map(&:strip).zip(self.values.map(&:strip).empty_strings_to_nil).to_h
  end
end

module LocaleImportExport
  def self.locate_locale_files(search_pattern, locales_path)
    Dir.entries(locales_path).select { |filename| filename =~ search_pattern }.map { |e| "#{locales_path}"+e }
  end

  def self.append_locale_name_to_hash(hash, filename)
    hash["language"] = filename.scan(/.*(_([a-z]{2,3})).*/).flatten.last
    hash
  end

  def self.export_locale_files_to_csv(search_pattern=/custom_.*(\.yml)$/, locales_path="/home/blubber/rails_workspace/lberg-map/config/locales/")
    locale_hashes = locate_locale_files(search_pattern, locales_path).map do |filename|
      append_locale_name_to_hash(YAML.load(File.open(filename)).restructure_hash, filename)
    end
    if locale_hashes.any?
      File.open("#{locales_path}locales_table.csv", 'wt') do |f|
        f.puts locale_hashes.first.keys.join(', ')
        locale_hashes.each do |hash|
          f.puts hash.values.join(', ')
        end
      end
    else
      puts "No locale files could be found using the given search pattern!"
    end
  end

  def self.update_locale_files_from_csv(
    import_from_path:,
    locale_folder:,
    filename_pattern:,
    languages:)
    file_to_import = File.open(import_from_path)
    CSV.foreach(file_to_import.path, headers: true).with_index(2) do |row, i|
      row = row.to_h.trim_hash_elements
      if languages.include?(row['language'])
        outfile = "#{yml_folder}" + Dir.entries(yml_folder).grep(/#{filename_pattern}_#{row['language']}/).first
        structure = YAML.load(File.open(outfile))
        File.open("#{outfile}1", 'w+') { |f| f.write structure.find_and_replace_with(row).to_yaml } if structure
      end
    end
  end
end
