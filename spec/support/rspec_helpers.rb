module RSpecHelpers
  def login_as(user)
    session[:user_id] = user.id
  end

  def logout
    session[:user_id] = nil
  end

  def extract_attributes(obj)
    obj.attributes.except("id", "created_at", "updated_at")
  end

  def switch_geocoder_stub
    # Redefine geocoder response to match geocoder return
    Geocoder::Lookup::Test.set_default_stub(
      [{ data: {
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
          'type' => 'house',
          }
        }
      }]
    )
  end
end
