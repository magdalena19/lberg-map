module PlaceImages
  def image_paths
    images.map(&:url)
  end

  def all_image_thumbnails
    images.map { |img| img.versions[:thumbnail] }
  end

  def image_dimensions(image_collection:)
    image_collection.map do |img|
      {
        img => MiniMagick::Image.open(img.file.file)[:dimensions]
      }
    end
  end
end
