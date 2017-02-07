describe PlacesController do
  before do
    Sidekiq::Testing.inline!
  end

  def extract_attributes(obj)
    obj.attributes.except("id", "created_at", "updated_at")
  end

  def post_valid_place
    post :create, place: { name: 'Kiezspinne',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                           description_en: 'This is a valid place',
                           categories: [] }
    Place.find_by(name: 'Kiezspinne')
  end

  def update_reviewed_description(place)
    put :update, id: place.id, place: { description_en: 'This description has been changed!' }

    place.translations.reload
    place
  end

  context 'GET #index' do
    # TODO check on cookies...
    it 'Does not crash with not up-to-date session_places cookie' do
      @request.cookies[:created_places_in_session] = [1, 2, 3, 4, 5, 772_348_7]
      get :index
      expect(response).to render_template 'places/index'
    end
  end

  context 'GET #new' do
      it 'populates new place in @place' do
        get :new
        expect(assigns(:place)).to be_a(Place)
      end

      it 'renders :new template' do
        get :new
        expect(response).to render_template 'places/new'
      end
  end

  context 'POST #create' do
    # TODO express as receive test
    it 'Place with lat_lon provided does not need to be geocoded on create' do
      post :create, place: { name: 'PlaceWithLatLong',
                             latitude: 62.0,
                             longitude: 10.0,
                             email: 'schnipp@schnapp.com',
                             homepage: 'http://schnapp.com',
                             phone: '03081618254',
                             description: 'This is a reviewed_place' }
      new_place = Place.find_by(name: 'PlaceWithLatLong')
      expect([new_place.latitude, new_place.longitude]).to eq([62.0, 10.0])
    end

    it 'Enqueues auto_translation task after create' do
      unreviewed_place = create :place, :unreviewed
      Sidekiq::Testing.fake! do
        expect {
          post :create, place: extract_attributes(unreviewed_place)
        }.to change { TranslationWorker.jobs.size }.by(1)
      end
    end

    it 'Translations of reviewed place are also reviewed on create' do
      login_as create(:user)
      valid_new_place = post_valid_place

      valid_new_place.translations.each do |translation|
        expect(translation.reviewed).to be true
      end
    end

		context 'Place created by guest user' do
      before do
        logout
      end

      it 'is not reviewed' do
        valid_new_place = post_valid_place
        expect(valid_new_place).not_to be(:reviewed)
      end

      it 'has no version history' do
        valid_new_place = post_valid_place
        expect(valid_new_place.versions.length).to be 1
      end
    end

    context 'Place-translations of place created by guest user' do
      before do
        logout
      end

      it 'are not reviewed' do
        valid_new_place = post_valid_place

        valid_new_place.translations.each do |translation|
          expect(valid_new_place).not_to be(:reviewed)
        end
      end

      it 'have no version history' do
        valid_new_place = post_valid_place

        valid_new_place.translations.each do |translation|
          expect(translation.versions.length).to be 1
        end
      end

      it 'have correct auto-translation flags' do
        valid_new_place = post_valid_place
        auto_translations = valid_new_place.translations.reject { |t| t.locale == :en }

        valid_new_place.translations.each do |translation|
          if auto_translations.include? translation
            expect(translation.auto_translated).to be true
          else
            expect(translation.auto_translated).to be false
          end
        end
      end
    end

    context 'Place created by authorized user' do
      before do
        login_as create :user
      end

      it 'is reviewed' do
        valid_new_place = post_valid_place

        expect(valid_new_place.reviewed).to be true
      end

      it 'has no version history' do
        valid_new_place = post_valid_place

        expect(valid_new_place.versions.count).to be 1
      end
    end

    context 'Place-translations created by authorized user' do
      before do
        login_as create :user
      end

      it 'are reviewed' do
        valid_new_place = post_valid_place

        valid_new_place.translations.each do |translation|
          expect(translation.reviewed).to be true
        end
      end

      it 'have no version history' do
        valid_new_place = post_valid_place

        valid_new_place.translations.each do |translation|
          expect(translation.versions.count).to be 1
        end
      end

      it 'have correct auto-translation flags' do
        valid_new_place = post_valid_place # posted description == en
        auto_translations = valid_new_place.translations.reject { |t| t.locale == :en }

        valid_new_place.translations.each do |translation|
          if auto_translations.include? translation
            expect(translation.auto_translated).to be true
          else
            expect(translation.auto_translated).not_to be true
          end
        end
      end

    end
  end

  context 'PUT #update' do
    let(:reviewed_place) { create :place, :reviewed }

    it 'Cannot update place if is not reviewed' do
      skip('TEST FAILS CURRENTLY, WAIT FOR REFACTOR IN PLACES CONTROLLER')
      unreviewed_place = create :place, :unreviewed
      put :update, id: unreviewed_place.id, place: { name: 'Some other name' }
      unreviewed_place.reload
      expect(unreviewed_place.name).not_to eq('Some other name')
    end
    
    it 'Cannot update translation if is not reviewed' do
      skip('TEST FAILS CURRENTLY, WAIT FOR REFACTOR IN PLACES CONTROLLER')
      put :update, id: reviewed_place.id, place: { description_en: 'This description has been changed!' }
      reviewed_place.reload

      put :update, id: reviewed_place.id, place: { description_en: 'Some other description text' }
      reviewed_place.reload
      expect(reviewed_place.description_en).not_to eq('Some other description text')
    end

    context 'Place updated by guest user' do
      before do
        logout

        put :update, id: reviewed_place.id, place: { name: 'Some other name' }
        reviewed_place.reload
      end

      it 'is being accepted' do
        expect(reviewed_place.name).to eq('Some other name')
      end

      it 'is not reviewed' do
        expect(reviewed_place.reviewed).to be false
      end

      it 'has version history' do
        expect(reviewed_place.versions.count).to be 2
      end
    end

    context 'Translation updated by guest user' do
      let(:reviewed_place) { create :place, :reviewed }

      before do
        logout

        put :update, id: reviewed_place.id, place: { description_en: 'This description has been changed!' }
        reviewed_place.reload
        @en_translation = reviewed_place.translations.select { |t| t.locale == :en }.first
      end

      it 'Guest can update reviewed translation' do
        expect(@en_translation.description).to eq('This description has been changed!')
        expect(reviewed_place.reviewed).to be true
      end

      it 'Translation updated by guest is not reviewed' do
        expect(@en_translation.reviewed).to be false
      end

      it 'Translation updated by guest has version history' do
        expect(@en_translation.versions.length).to be 2
      end
    end

    context 'Place updated by authorized user' do
      let(:user) { create :user }

      before do
        login_as user
        put :update, id: reviewed_place.id, place: { name: 'Some other name' }
        reviewed_place.reload
      end

      it 'changes attributes' do
        expect(reviewed_place.name).to eq('Some other name')
      end

      it 'is reviewed' do
        expect(reviewed_place.reviewed).to be true
      end

      it 'has no version history' do
        expect(reviewed_place.versions.count).to be 1
      end
    end

    context 'Place-translation updated by authorized user' do
      let(:user) { create :user }

      before do
        login_as user

        put :update, id: reviewed_place.id, place: { description_en: 'This description has been changed!' }
        reviewed_place.reload
        @en_translation = reviewed_place.translations.select { |t| t.locale == :en }.first
      end

      it 'updates description text' do
        expect(@en_translation.description).to eq('This description has been changed!')
      end

      it 'is reviewed' do
        expect(@en_translation.reviewed).to be true
      end

      it 'has no history' do
        expect(@en_translation.versions.count).to be 1
      end
    end
  end

  context 'DELETE #destroy' do
    it 'Authorized user can delete place' do
      login_as create(:user)
      reviewed_place = create :place, :reviewed
      expect {
        delete :destroy, id: reviewed_place.id
      }.to change { Place.count }.by(-1)
    end

    it 'Guest user cannot delete place' do
      logout
      reviewed_place = create :place, :reviewed
      expect {
        delete :destroy, id: reviewed_place.id
      }.to change { Place.count }.by(0)
    end
  end
end
