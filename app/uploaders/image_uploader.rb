class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/images/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :thumbnail do
    # process resize_to_fit: [30, 30]
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
