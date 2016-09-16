require 'import_from_file'

task import_from_csv: :environment do
  ImportFromFile.import_from_csv ARGV[1]
end
