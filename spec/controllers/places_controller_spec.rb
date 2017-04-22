describe PlacesController do
  before do
    Sidekiq::Testing.inline!
  end

  def extract_attributes(obj)
    obj.attributes.except('id', 'created_at', 'updated_at')
  end

  def post_valid_place(map_token:)
    post :create, place: attributes_for(:place, name: 'Kiezspinne', description_en: 'This is a description'), map_token: map_token
  end

  def update_reviewed_description(place)
    patch :update, id: place.id, place: { description_en: 'This description has been changed!' }

    place.translations.reload
    place
  end

  context 'GET #index' do
    let(:map) { create :map, :full_public }

    # TODO Whats this spec about?
    it 'Does not crash with not up-to-date session_places cookie' do
      @request.cookies[:created_places_in_session] = [1, 2, 3, 4, 5, 772_348_7]
      get :index, map_token: map.public_token

      expect(response).to render_template 'places/index'
    end

    it 'Populates all places in @places' do
      create_list(:place, 3, :reviewed, map: map)
      get :index, map_token: map.public_token

      expect(assigns(:places).count).to be 3
    end
  end

  context 'GET #new' do
    let(:map) { create :map, :full_public }

    it 'populates new place in @place' do
      get :new, map_token: map.secret_token
      expect(assigns(:place)).to be_a(Place)
    end

    it 'renders :new template' do
      get :new, map_token: map.secret_token
      expect(response).to render_template :new
    end

    it 'sets current user as privileged when route accessed via secret link' do
      get :new, map_token: map.secret_token
      expect(assigns(:current_user)).to be_a(PrivilegedGuestUser)
    end
  end

  context 'POST #create' do
    let(:map) { create :map, :full_public }

    it 'accepts new geofeatures district, country and federal state' do
      post :create, map_token: map.secret_token, place: attributes_for(:place, :unreviewed,
                                                                       federal_state: 'SomeState',
                                                                       country: 'SomeCountry',
                                                                       district: 'SomeDistrict')
      new_place = Place.find_by(country: 'SomeCountry')
      expect(new_place.district).to eq 'SomeDistrict'
      expect(new_place.federal_state).to eq 'SomeState'
      expect(new_place.country).to eq 'SomeCountry'
    end

    it 'redirects to correct map show' do
      post :create, map_token: map.public_token, place: attributes_for(:place, :unreviewed,
                                                                       federal_state: 'SomeState',
                                                                       country: 'SomeCountry',
                                                                       district: 'SomeDistrict')
      expect(response).to redirect_to map_path(map_token: map.public_token, latitude: 52.5, longitude: 13.45)
    end

    it 'Enqueues auto_translation task after create' do
      Sidekiq::Testing.fake! do
        expect {
          post :create, place: attributes_for(:place, :unreviewed), map_token: map.public_token
        }.to change { TranslationWorker.jobs.size }.by(3)
      end
    end

    it 'creates category that is not there' do
      Category.create name: 'OldCat', map: map
      new_place = create :place, :unreviewed, categories: 'NewCat', map: map

      post :create, place: extract_attributes(new_place), map_token: map.secret_token

      expect(Category.all.map(&:name)).to include('NewCat')
    end

    it 'Does not enqueue auto_translation unless true in settings' do
      map = create :map, auto_translate: false
      Sidekiq::Testing.fake! do
        expect {
          post :create, place: attributes_for(:place, :unreviewed), map_token: map.secret_token
        }.to change { TranslationWorker.jobs.size }.by(0)
      end
    end

    it 'Does not enqueue auto_translation unless true in settings' do
      place = create :place, :reviewed, map: create(:map, :full_public)
      patch :update, id: place.id, place: attributes_for(:place, :reviewed), map_token: place.map.secret_token

      expect(place.reload.versions.count).to eq 1
    end

    context 'Restricted public maps' do
      let(:map) { create :map, :restricted_access }

      it 'is rejected if place ressources access is restricted' do
        logout
        expect(:post => places_path(map_token: map.public_token)).not_to be_routable
      end
    end

    context 'On public maps' do
      let(:map) { create :map, :full_public }

      context 'Place created by guest user' do
        before do
          logout
          post_valid_place(map_token: map.public_token)
          @valid_new_place = Place.last
        end

        it 'is not reviewed' do
          expect(@valid_new_place).not_to be(:reviewed)
        end

        it 'has no version history' do
          expect(@valid_new_place.versions.length).to be 1
        end
      end

      context 'Place-translations of place created by guest user' do
        before do
          logout
          post_valid_place(map_token: map.public_token)
          @valid_new_place = Place.last
        end

        it 'are not reviewed' do
          @valid_new_place.translations.each do |translation|
            expect(@valid_new_place).not_to be(:reviewed)
          end
        end

        it 'have no version history' do
          @valid_new_place.translations.each do |translation|
            expect(translation.versions.length).to be 1
          end
        end

        it 'have correct auto-translation flags' do
          auto_translations = @valid_new_place.translations.reject { |t| t.locale == :en }

          @valid_new_place.translations.each do |translation|
            if auto_translations.include? translation
              expect(translation.auto_translated).to be true
            else
              expect(translation.auto_translated).to be false
            end
          end
        end
      end
    end

    context 'Place created by privileged user' do
      before do
        post_valid_place(map_token: map.secret_token)
        @valid_new_place = Place.last
      end

      it 'is reviewed' do
        expect(@valid_new_place.reviewed).to be true
      end

      it 'has no version history' do
        expect(@valid_new_place.versions.count).to be 1
      end
    end

    context 'Place created by registered user' do
      before do
        login_as create :user
        post_valid_place(map_token: map.public_token)
        @valid_new_place = Place.last
      end

      it 'is reviewed' do
        expect(@valid_new_place.reviewed).to be true
      end

      it 'has no version history' do
        expect(@valid_new_place.versions.count).to be 1
      end
    end

    context 'Place-translations created by authorized user' do
      before do
        login_as create :user, email: 'foo@bar.org'
        post_valid_place(map_token: map.public_token)
        @valid_new_place = Place.last
      end

      it 'are reviewed' do
        @valid_new_place.translations.each do |translation|
          expect(translation.reviewed).to be true
        end
      end

      it 'have no version history' do
        @valid_new_place.translations.each do |translation|
          expect(translation.versions.count).to be 1
        end
      end

      it 'have correct auto-translation flags' do
        auto_translations = @valid_new_place.translations.reject { |t| t.locale == :en }

        @valid_new_place.translations.each do |translation|
          if auto_translations.include? translation
            expect(translation.auto_translated).to be true
          else
            expect(translation.auto_translated).not_to be true
          end
        end
      end

      it 'Translations of reviewed place are also reviewed on create' do
        login_as create(:user, email: 'batz@bar.org')
        @valid_new_place.translations.each do |translation|
          expect(translation.reviewed).to be true
        end
      end
    end
  end

  context 'patch #update' do
    let(:map) { create :map, :full_public }
    let(:private_map) { create :map, :private, allow_guest_commits: false, is_public: false }
    let(:reviewed_place) { create :place, :reviewed, map: map}

    it 'redirects to map show view' do
      patch :update, id: reviewed_place.id, place: { description_en: 'This description has been changed!' }, map_token: map.public_token
      expect(response).to redirect_to map_path(map_token: map.public_token, latitude: 52.5, longitude: 13.45)
    end

    context 'restrict non-reviewed access' do
      it 'Cannot update place if is not reviewed' do
        unreviewed_place = create :place, :unreviewed, map: map
        patch :update, id: unreviewed_place.id, place: { name: 'Some other name' }, map_token: map.public_token
        unreviewed_place.reload
        expect(unreviewed_place.name).not_to eq('Some other name')
      end

      it 'Cannot update translation if is not reviewed' do
        patch :update, id: reviewed_place.id, place: { description_en: 'This description has been changed!' }, map_token: map.public_token
        reviewed_place.reload
        expect(reviewed_place.translations.find_by(locale: :en).reviewed).to be false

        patch :update, id: reviewed_place.id, place: { description_en: 'Some other description text' }, map_token: map.public_token
        reviewed_place.reload
        expect(reviewed_place.description_en).not_to eq('Some other description text')
      end
    end

    context 'update on categories' do
      it 'changes record references accordingly' do
        patch :update, id: reviewed_place.id, place: { categories: 'Bar, Hooray' }, map_token: map.public_token
        reviewed_place.reload
        categories = %w[Bar Hooray].map { |name| Category.find_by(name: name).id }

        expect(reviewed_place.categories).to eq categories.join(',')
      end
    end


    context 'Place updated by guest user' do
      before do
        logout
        patch :update, id: reviewed_place.id, place: { name: 'Some other name' }, map_token: map.public_token
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

      context 'Access restrictions' do
        let(:map) {create :map, :restricted_access  }
        let(:another_reviewed_place) { create :place, :reviewed, map: map }

        it 'if map access is semi-public' do
          expect(patch: place_path(id: another_reviewed_place.id, map_token: map.public_token), place: {}).not_to be_routable
        end
      end
    end


    context 'Reviewewd translation' do
      let(:map) { create :map, :full_public }
      let(:reviewed_place) { create :place, :reviewed, map: map}
      let(:restricted_map) {create :map, :restricted_access  }
      let(:another_reviewed_place) { create :place, :reviewed, map: map }

      before do
        logout

        patch :update, id: reviewed_place.id, place: { description_en: 'This description has been changed!' }, map_token: map.public_token
        reviewed_place.reload
        @en_translation = reviewed_place.translations.select { |t| t.locale == :en }.first
      end

      it 'can be updated by guest user' do
        expect(@en_translation.description).to eq('This description has been changed!')
        expect(reviewed_place.reviewed).to be true
      end

      it 'updated by guest is not reviewed' do
        expect(@en_translation.reviewed).to be false
      end

      it 'updated by guest has version history' do
        expect(@en_translation.versions.length).to be 2
      end

      it 'is rejected if map is semi-public' do
        expect(patch: place_path(id: another_reviewed_place.id, map_token: restricted_map.public_token), place: { description_en: 'This description has been changed!' }).not_to be_routable
      end
    end

    context 'Place updated by authorized user' do
      let(:user) { create :user }

      before do
        login_as user
        patch :update, id: reviewed_place.id, place: { name: 'Some other name' }, map_token: map.secret_token
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

        patch :update, id: reviewed_place.id, place: { description_en: 'This description has been changed!' }, map_token: map.secret_token
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
    let(:map) { create :map, :full_public }

    before do
      @place = create :place, :reviewed, map: map
    end

    it 'Authorized user can delete place' do
      login_as create(:user)
      expect {
        delete :destroy, id: @place.id, map_token: map.secret_token
      }.to change { Place.count }.by(-1)
    end
    
    it 'Authorized user can delete place via ajax' do
      login_as create(:user)
      expect {
        xhr :delete, :destroy, id: @place.id, map_token: map.secret_token
      }.to change { Place.count }.by(-1)
    end

    it 'Guest user cannot delete place' do
      logout
      expect {
        delete :destroy, id: @place.id, map_token: map.public_token
      }.to change { Place.count }.by(0)
    end
  end
end
