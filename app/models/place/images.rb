module PlaceImages
  def image_paths
    images.map(&:url)
  end
end
