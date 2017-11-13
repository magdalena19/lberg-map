require 'rails_helper'

RSpec.describe Map, type: :model do
  context 'Attributes' do
    it { is_expected.to respond_to :title }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :imprint }
    it { is_expected.to respond_to :is_public }
    it { is_expected.to respond_to :public_token }
    it { is_expected.to respond_to :secret_token }
    it { is_expected.to respond_to :maintainer_email_address }
    it { is_expected.to respond_to :auto_translate }
    it { is_expected.to respond_to :translation_engine }
    it { is_expected.to respond_to :allow_guest_commits }
    it { is_expected.to respond_to :supported_languages }
    it { is_expected.to respond_to :password_digest }
    it { is_expected.to respond_to :last_visit }
  end

  context 'Callbacks' do
    it 'should create secret token on create for public maps' do
      map = create :map, :full_public
      expect(map.secret_token).to be_a(String)
    end

    it 'should create public token on create for public maps' do
      map = create :map, :full_public
      expect(map.public_token).to be_a(String)
    end

    it 'should create secret token on create for private maps' do
      map = create :map, :private
      expect(map.secret_token).to be_a(String)
    end
  end

  context 'Associations' do
    it { is_expected.to have_many :places }
    it { is_expected.to have_many :categories }
    it { is_expected.to have_many :messages }
    it { is_expected.to belong_to :user }

    context 'delete map' do
      it 'deletes places on map' do
        map = create :map, :full_public
        place = create :place, :reviewed, map: map

        expect { map.destroy }.to change { Place.count }.by(-1)
      end
    end
  end

  context 'Validations' do
    it 'validates map maintainer email address if present' do
      map = build :map, maintainer_email_address: 'foo@bar'
      expect(map).not_to be_valid
    end

    it 'validates translation engine if auto_translation on' do
      map = build :map, :full_public, translation_engine: ''
      expect(map).not_to be_valid
    end

    it 'does not pass invalid translation engines' do
      map = build :map, :full_public, translation_engine: 'unknownEngine'
      expect(map).not_to be_valid
    end

    it 'does not pass empty secret_token' do
      map = build :map, :full_public, secret_token: ''
      expect(map).not_to be_valid
    end

    it 'does not pass non-unique secret_token' do
      map1 = create :map, :full_public, secret_token: 'secret'
      map2 = build :map, :full_public, secret_token: 'secret'
      expect(map2).not_to be_valid
    end

    it 'cannot have title longer than 25 characters' do
      map = build :map, :full_public, title: 'a'*26

      expect(map).not_to be_valid
    end

    it 'cannot have no supported_languages' do
      map = build :map, :full_public, supported_languages: []
      
      expect(map).not_to be_valid
    end

    context 'Password protection' do
      it 'Map password has to be longer or equal 5 chars' do
        map = build :map, :full_public, password: '1234', password_confirmation: '1234'
      
        expect(map).not_to be_valid
      end

      it 'Does not accept unequal passwords' do
        map = build :map, :full_public, password: 'abcdef', password_confirmation: 'Something different'
      
        expect(map).not_to be_valid
      end
    end
  end

  context 'Class methods' do
    it 'can query all guest maps' do
      expect(Map).to respond_to(:guest_maps)
    end
  end

  context 'Instance methods' do 
    before do
      @map = create :map, :full_public 
      @reviewed_places = create_list :place, 4, :reviewed, map: @map
      @unreviewed_places = create_list :place, 2, :unreviewed , map: @map
      @reviewed_events = create_list :event, 5, map: @map
      @unreviewed_events = create_list :event, 1, :unreviewed, map: @map
      create :settings, expiry_days: 10
    end

    it 'can query maps to expire for days till destruction' do
      guest_map = create :map, :public_guest_map, last_visit: Date.today - 2.days

      expect(guest_map.days_left_till_destruction).to eq 8
    end

    it 'returns expiry days for new map' do
      guest_map = build :map, :public_guest_map

      expect(guest_map.days_left_till_destruction).to eq 10
    end

    it 'returns exact number of reviewed places' do
      expect(@map.reviewed_places.count).to eq 4
    end

    it 'returns exact number of unreviewed places' do
      expect(@map.unreviewed_places.count).to eq 2
    end

    it 'returns exact number of reviewed events' do
      expect(@map.reviewed_events.count).to eq 5
    end

    it 'returns exact number of unreviewed events' do
      expect(@map.unreviewed_events.count).to eq 1
    end

    context 'Password protection' do
      it 'can be asked if password set' do
        expect(@map).to respond_to(:password_protected?)
      end

      it 'password_set? responds false if no password set' do
        map = build :map, :full_public

        expect(map.password_protected?).to eq false
      end

      it 'password_set? responds true if password set' do
        map = build :map, :full_public, password: 'secret', password_confirmation: 'secret'

        expect(map.password_protected?).to eq true
      end

      it 'authenticates map' do
        map = create :map, :full_public, password: 'secret', password_confirmation: 'secret'

        expect(map.authenticated?(attribute: 'password', token: 'secret')).to be true
      end

      it 'does not authenticate map if given password is invalid' do
        map = create :map, :full_public, password: 'secret', password_confirmation: 'secret'

        expect(map.authenticated?(attribute: 'password', token: 'wrong')).to be false
      end
    end
  end
end
