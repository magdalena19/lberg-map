class PlaceAttachment < ActiveRecord::Base
   mount_uploader :image, ImageUploader
   belongs_to :place

   validate :max_image_count

   def max_image_count
     return false unless self.place
     if self.place.place_attachments(:reload).count >= self.place.map.images_per_post
       errors.add(:base, :exceeded_quota)
     end
   end
end
