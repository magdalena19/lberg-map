require 'locale_files_import_export'

desc 'Convert comma-separated csv to locale YAML files'
task csv_to_locale_files: :environment do
  ARGV.each { |a| task a.to_sym do ; end }
  LocaleImportExport.update_locale_files_from_csv(
    import_from_path: ARGV[1],
    locale_folder: ARGV[2],
    filename_pattern: ARGV[3],
    languages: ARGV[4..-1],
  )
end
