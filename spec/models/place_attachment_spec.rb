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

  it 'will be deleted with parent place' do
    @place = create :place, name: 'New place'
    @image = create :place_attachment, place_id: @place.id
    expect { @place.destroy }.to change(PlaceAttachment, :count).by(-1) 
  end

  it 'can only be created as often as map setting allows' do
    @map = create :map, images_per_post: 2
    @place = create :place, name: 'New place', map_id: @map.id
    create :place_attachment, place_id: @place.id
    create :place_attachment, place_id: @place.id
    expect(build :place_attachment, place_id: @place.id).to_not be_valid
  end
end
