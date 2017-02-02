require_relative '../test_helper'

class TranslationsReviewControllerTest < ActionController::TestCase
  def setup
    @new_place = Place.create(
                    name: 'Kiezspinne',
                    street: 'Schulze-Boysen-Straße',
                    house_number: '13',
                    postal_code: '10365',
                    city: 'Berlin',
                    description_en: 'bla bli blubs',
                    latitude: 13,
                    longitude: 52,
                    reviewed: false
                  )

    @place_with_unreviewed_changes = Place.create(
                                        name: 'Magda19',
                                        street: 'Magdalenenstraße',
                                        house_number: '19',
                                        postal_code: '10365',
                                        city: 'Berlin',
                                        description_en: 'This is a description.',
                                        latitude: 13,
                                        longitude: 52,
                                        reviewed: true
                                      )

    @place_with_unreviewed_changes.update_attributes(name: 'Magda', description: 'This is an updated description.')
    @translations = @place_with_unreviewed_changes.translations
    @user = users :Norbert
    session[:user_id] = @user.id
  end

  test 'unreviewed translations can be confirmed' do
    id = @translations.find_by(description: 'This is an updated description.').id
    get :confirm, id: id

    assert @translations.find_by(description: 'This is an updated description.')
    assert_not @translations.find_by(description: 'This is a description.')
  end

  test 'Refusing of unreviewed Translation only deletes unreviewed version' do
    id = @translations.find_by(description: 'This is an updated description.').id
    get :refuse, id: id

    assert @translations.find_by(description: 'This is a description.')
    assert_not @translations.find_by(description: 'This is an updated description.')
  end
end
