require 'map_rotate'

describe MapRotate do
  before do
    create :settings, expiry_days: 10
    @expired_maps = create_list :map, 3, :full_public, last_visit: Date.today - 11.days, user: nil
    create :map, :full_public, last_visit: Date.today - 2.days
  end

  it 'responds to delete method' do
    expect(MapRotate).to respond_to(:delete_expired_guest_maps)
  end

  it 'can collect all expired maps' do
    expect(MapRotate).to respond_to(:expired_maps)
  end

  it 'can query all expired maps' do
    expect(MapRotate.expired_maps.sort).to eq @expired_maps.sort
  end

  it 'only queries guest maps' do
    user = create :user
    create_list :map, 2, :full_public, user: user, last_visit: Date.today - 11.days

    expect(MapRotate.expired_maps.sort).to eq @expired_maps.sort
  end

  it 'can delete all expired maps' do
    expect {
      MapRotate.delete_expired_guest_maps
    }.to change { Map.count }.by(-3)
  end
end
