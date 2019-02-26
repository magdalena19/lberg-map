class PlaceAttachment < ActiveRecord::Base
   mount_uploader :image, ImageUploader
   belongs_to :place
end
