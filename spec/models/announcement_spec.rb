describe Announcement do
  let(:user) { create :user }
  let(:announcement) { create :announcement, user: user, content: '<center>SomeContent</center>' }

  context 'Associations' do
    it { is_expected.to belong_to :map }
  end

  # Check validation working
  it 'Header has to be min 5 and max 100 characters' do
    ['', 'a' * 4, 'a' * 101].each do |e|
      expect(announcement.update_attributes(header: e)).to be_falsey
    end
  end

  it 'Content cannot be blank' do
    expect(announcement.update_attributes(content: '')).to be_falsey
  end

  it 'html should be sanitized' do
    expect(announcement.content).to eq('SomeContent')
  end
end
