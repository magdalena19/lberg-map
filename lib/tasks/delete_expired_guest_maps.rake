require 'map_rotate'

desc 'Fetch and delete all guest maps older than Admin::Setting.expiry_days if > 0'
task delete_expired_guest_maps: :environment do
  MapRotate.delete_expired_guest_maps
end
