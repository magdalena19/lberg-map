require 'locale_files_import_export'

desc 'Merge locales to comma-separated csv file'
task locale_files_to_csv: :environment do
  LocaleImportExport.update_locale_files_from_csv(/custom_.*(\.yml)$/, '/home/blubber/rails_workspace/lberg-map/config/locales/')
end
