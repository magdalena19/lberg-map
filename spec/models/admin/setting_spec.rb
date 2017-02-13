require 'rails_helper'

RSpec.describe Admin::Setting, type: :model do
  it 'can add setting' do
    expect {
      Admin::Setting.create!(key: 'site_title', value: 'SomeTitle')
    }.to change { Admin::Setting.count }.by(1)
  end

  it 'cannot add empty settings' do
    expect {
      Admin::Setting.create!(key: '', value: '')
    }.to change { Admin::Setting.count }.by(0)
  end
end
