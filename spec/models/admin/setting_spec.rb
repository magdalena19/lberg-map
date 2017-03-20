require 'rails_helper'

RSpec.describe Admin::Setting, type: :model do
  before do
    create :settings, :public
  end
  
  it 'can add setting' do
    expect {
      Admin::Setting.create(auto_translate: true, is_private: true)
    }.to change { Admin::Setting.count }.by(1)
  end

  it 'passes settings value queries to class level' do
    expect(Admin::Setting).to respond_to(:app_title)
  end

  it 'can return all_settings list as hash' do
    expect(Admin::Setting.all_settings).to be_a(Hash)
  end

  it 'lists all available machine translation engines' do
    expect(Admin::Setting).to respond_to(:translation_engines)
    expect(Admin::Setting.translation_engines).to be_a(Array)
  end

  context 'Validations' do
    it 'cannot set app titles longer than 20 characters' do
      setting = build :settings, :public, app_title: "A"*21
      expect(setting).to be_invalid
    end

    # TODO Handle that more flexible later...
    it 'Must have valid maintainer email address' do
      setting = build :settings, :public, maintainer_email_address: 'foo@bar'
      expect(setting).to be_invalid
    end
  end
end
