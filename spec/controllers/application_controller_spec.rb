RSpec.describe MapsController, type: :controller do
  context 'Set locale' do
    it 'Sets locale if submitted via params'
    it 'Sets @locale_not_selected'
    it 'Falls back to first map language if requested locale not supported on map'
  end
end
