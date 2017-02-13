require 'rails_helper'

RSpec.describe Admin::Setting, type: :model do
  it 'can add setting' do
    expect {
      Admin::Setting.create(auto_translate: true, is_private: true)
    }.to change { Admin::Setting.count }.by(1)
  end

  it 'passes settings value queries to class level' do
    expect(Admin::Setting).to respond_to(:app_title)
  end

  it 'loads default settings' do
    expect(Admin::Setting.app_title).not_to be_nil
  end

  it 'can return all_settings list as hash' do
    expect(Admin::Setting.all_settings).to be_a(Hash)
  end
end
