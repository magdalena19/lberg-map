describe Place do
  let(:place) { build :place, :reviewed }

  before do
    create :settings
  end

  it 'can save place to database' do
    place.save
    expect(Place.find(place.id)).to eq(place)
  end

  context 'Validate' do
    it 'empty place as invalid' do
      expect(Place.new).not_to be_valid
    end

    it 'name should not be blank' do
      place.name = ''
      expect(place).not_to be_valid
    end

    it 'malformatted phone numbers as invalid' do
      ['03', '03'*12].each do |phone_number|
        expect(place.update_attributes(phone: phone_number)).to be_falsey
        expect(place.errors.messages[:phone]).to eq([ 'is incorrectly formatted!' ])
      end
    end

    it 'malformatted email addresses as invalid' do
      ['foo@bar', 'foo@.bar', 'bar@'].each do |mail_address|
        expect(place.update_attributes(email: mail_address)).to be_falsey
        expect(place.errors.messages[:email]).to eq([ 'is incorrectly formatted!' ])
      end
    end

    it 'malformatted homepage URLs as invalid' do
      ['http:/heise', 'heise.', 'heise.d'].each do |homepage|
        expect(place.update_attributes(homepage: homepage)).to be false
        expect(place.errors.messages[:homepage]).to eq([ 'is incorrectly formatted!' ])
      end
    end

    it 'that place contact data shall be valid' do
      expect(place.update_attributes(phone: '0304858')).to be true
      expect(place.update_attributes(email: 'foo@batz.bar')).to be true
      expect(place.update_attributes(homepage: 'http://foo.bar')).to be true
      expect(place.update_attributes(homepage: 'www.foo.bar')).to be true
      expect(place.update_attributes(homepage: 'foo.bar')).to be true
    end

    it 'that district column exists' do
      expect(Place.new).to respond_to(:district)
    end

    it 'that federal_state column exists' do
      expect(Place.new).to respond_to(:federal_state)
    end

    it 'that country column exists' do
      expect(Place.new).to respond_to(:country)
    end

    it 'cannot end sooner than start-date' do
      event = build :event
      event.start_date = Date.today
      event.end_date = Date.today - 1.days
      expect(event).not_to be_valid
    end

    it 'event cannot end sooner than it started' do
      event = build :event
      event.start_date = Date.today
      event.end_date = Date.today - 1.days
      expect(event).not_to be_valid
    end
  end

  context 'Callbacks' do
    it 'Assure correctly securing URLs' do
      place.homepage = 'http://www.heise.de'
      place.save

      expect(Place.find(place.id).homepage).to eq('https://heise.de')
    end

    it 'Sanitze HTML correctly' do
      place = create :place, :unreviewed, description_en: '<b>This is the description.</b>'
      expect(Place.find(place.id).description_en).to eq('<b>This is the description.</b>')
    end

    it 'duplicate entries not valid' do
      skip('To be defined: Duplicate entries not valid')
    end

    context 'Geocoding' do
      it 'Place with lat/lon does not need to be geocoded' do
        place = build :place, :unreviewed, latitude: 60.0, longitude: 10.0
        place.save
        expect([place.latitude, place.longitude]).to eq([60.0, 10.0])
      end

      it 'Places without lat/lon become geocoded' do
        place = build :place, :without_coordinates
        expect {
          place.save
        }.to change { place.latitude }.from(nil).to(52)
      end

      it 'automatically fills empty geofeatures from geocoding lookup' do
        place = build :place, :without_coordinates
        expect {
          place.save
        }.to change { place.federal_state }.from(nil).to('Berlin')
      end
    end

    it 'does not auto-translate if option is not set' do
      create :settings, :private
      expect(Admin::Setting.is_private).to be true
      new_place = create :place, :unreviewed
      new_place.tap do |place|
        expect(place.translations.map(&:auto_translated).any?).to be false
      end
    end
  end

  context 'can be an event' do
    it 'with start and end date' do
      expect(Place.new).to respond_to(:event)
      expect(Place.new).to respond_to(:start_date)
      expect(Place.new).to respond_to(:end_date)
    end

    it 'scopes all event type places' do
      create_list(:event, 3, :future)
      create_list(:event, 3, :past)
      create_list(:event, 3, :ongoing)

      expect(Place.all_events.count).to be 9
    end

    it "scopes future events" do
      create_list(:event, 3, :future)
      expect(Place.future_events.count).to be 3
    end

    it "scopes past events" do
      create_list(:event, 3, :past)
      expect(Place.past_events.count).to be 3
    end

    it "scopes ongoing events" do
      create_list(:event, 3, :ongoing)
      expect(Place.ongoing_events.count).to be 3
    end
  end

  context 'Auditing' do
    let(:place) { build :place, :unreviewed }

    it 'Version is 1 for new points' do
      place.save
      expect(place.reload.versions.count).to be 1
    end

    it 'Updating a point increases number of versions' do
      place.save
      expect {
        place.update(name: 'SomeOtherPlace')
      }.to change { place.versions.count }.by(1)
    end

    it 'Updating translation record does not increase associated place versions' do
      place.save
      expect {
        place.translation.update_attributes(description: 'This is some edit')
      }.to change { place.versions.count }.by(0)
    end

    it 'return nil for \'reviewed_version\' if no reviewed version' do
      place.save
      expect(place.reviewed_version).to be_nil
    end

    it 'return unreviewed version if \'reviewed\' = false, but no versions' do
      place.save
      expect(place.unreviewed_version).to eq(place)
    end

    it 'Assure place homepage links use https' do
      ['www.it.com', 'it.com', 'http://it.com'].each do |url|
        place.homepage = url
        place.save
        expect(place.homepage).to eq('https://it.com')
      end
    end
  end
end
