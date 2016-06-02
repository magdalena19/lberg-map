require 'csv'

module ImportFromFile
  def self.intersect_hash_by_keys(h1, h2)
    keys_in_h2 = h1.keys & h2.keys
    keys_in_h2.map { |k| [k, h1[k]] }.to_h
  end

  def self.get_category_ids(category_names)
    return [''] * Category.all.length if category_names.nil?
    names = category_names.split(/,|;/).map { |e| e.downcase.strip }
    Category.all.map do |c|
      names.include?(c.name.downcase) && c.id.to_s || ''
    end
  end

  def self.prepare_data_before_import(row)
    category_ids = get_category_ids(row['categories'])
    row = intersect_hash_by_keys(row.to_h, Place.new.attributes)
    row[:category_ids] = category_ids
    row
  end

  def self.push_error_to_logfile(log_path, imported_file, line_no, errors)
    File.open(log_path, 'a') do |logfile|
      logfile.puts "
      #{Date.today}: Import of #{imported_file.path} \n
      error on line_#{line_no}: #{errors.messages} \n"
    end
  end

  def self.import_from_csv(file_path)
    f = File.open(file_path)
  rescue => e
    Rails.logger { e.to_s }
  else
    error_count = import_count = 0
    logfile_path = "#{Rails.root}/log/import_from_file - #{Rails.env}.log"
    CSV.foreach(f.path, headers: true).with_index(2) do |row, i|
      p = Place.new prepare_data_before_import(row)
      if p.valid?
        p.save
        import_count += 1
      else
        error_count += 1
        push_error_to_logfile(logfile_path, f, i, p.errors)
      end
    end
    puts "Import from CSV file finished: #{import_count} row(s) imported,
    #{error_count} error(s). Parse #{logfile_path} for further information. \n \n"
  end
end
