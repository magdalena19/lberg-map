describe PlaceAttachment do
  context 'Associations' do
    it { is_expected.to belong_to :place }
  end

  it 'can be created' do
    @place = create :place, name: 'New place'
    @image = create :place_attachment, place_id: @place.id
    expect(@image).to be_valid
    expect(@place.images[0]).to include('ratmap_logo.jpg')
  end
end
