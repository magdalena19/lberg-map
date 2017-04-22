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
    it { is_expected.to have_many :announcements }
    it { is_expected.to have_many :messages }
    it { is_expected.to belong_to :user }
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
  end

  context 'Instance methods' do 
    before do
      @map = create :map, :full_public 
      @reviewed_places = create_list :place, 4, :reviewed, map: @map
      @unreviewed_places = create_list :place, 2, :unreviewed , map: @map
      @reviewed_events = create_list :event, 5, map: @map
      @unreviewed_events = create_list :event, 1, :unreviewed, map: @map
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
  end
end
