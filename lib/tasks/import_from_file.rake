require 'import_from_file'

task import_from_csv: :environment do
  MapRotate.delete_expired_guest_maps
end
