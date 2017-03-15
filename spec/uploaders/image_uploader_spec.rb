describe ImageUploader do
  include CarrierWave::Test::Matchers

  let(:place) { create :place, :reviewed }
  let(:upload) { ImageUploader.new(place, :place) }

  context 'storage' do
    it 'default path is set correctly' do
      expect(upload.store_dir).to eq "uploads/images/place/#{place.id}"
    end
  end

  context 'whitelisting' do
    it 'is enabled' do
      expect(upload.extension_whitelist).to eq %w[jpg jpeg gif png]
    end
  end

  context 'thumbnails' do
    it 'exist' do
      expect(upload).to respond_to(:thumbnail)
    end
  end
end
