class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  process resize_to_fit: [800, 800]
  validates :images, file_size: { maximum: 2.megabytes }

  def store_dir
    "uploads/images/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :thumbnail do
    process resize_to_fit: [50, 50]
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
