module MapRotate
  def self.delete_expired_guest_maps
    expired_maps.each { |map| map.destroy }
  end

  private

  def self.expired_maps
    expiry_date = Date.today - Admin::Setting.expiry_days

    Map.guest_maps.where.not(last_visit: expiry_date..Date.today).sort_by(&:id)
  end
end
