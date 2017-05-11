require 'place/geocoding'

describe PlaceGeocoding do
  it 'should prepare ruby geocoder gem output properly' do
    result = OpenStruct.new({
      'lat' => 52,
      'lon' => 12,
      'boundingbox' => [52.5, 52.3, 13.0, 12.5],
      address: {
        'house_number' => '19',
        'street' => 'Magdalenenstraße',
        'postcode' => '10365',
        'district' => 'Lichtenberg',
        'town' => 'Berlin',
        'state' => 'Berlin',
        'country' => 'Germany',
        'type' => 'house' }
    })

    prepared_result = PlaceGeocoding.prepare(search_results: result)

    expect(prepared_result).to eq expectance
  end

  it 'should prepare JS geocoder output properly' do
    result = OpenStruct.new({
      'lat' => 52,
      'lon' => 12,
      'boundingbox' => [52.5, 52.3, 13.0, 12.5],
      'house_number' => '19',
      'street' => 'Magdalenenstraße',
      'postcode' => '10365',
      'district' => 'Lichtenberg',
      'town' => 'Berlin',
      'state' => 'Berlin',
      'country' => 'Germany',
      'type' => 'house'
    })

    prepared_result = PlaceGeocoding.prepare(search_results: result)

    expect(prepared_result).to eq expectance
  end

  private

  def expectance
    { 
      latitude: 52,
      longitude: 12,
      house_number: '19',
      street: 'Magdalenenstraße',
      postal_code: '10365',
      district: 'Lichtenberg',
      city: 'Berlin',
      federal_state: 'Berlin',
      country: 'Germany',
    }
  end
end
