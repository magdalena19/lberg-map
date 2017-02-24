class PlaceParamsModifier
  attr_reader :params

  def initialize(place_params:, place: nil)
    @params = place_params
    @place = place

    if @place.present?
      check_and_filter_place_attr
      check_and_filter_descriptions
    end

    if place_params[:categories]
      category_param = place_params[:categories].sort || []
      @params[:categories] = category_param.reject(&:empty?).join(',')
    end

    if @place && @place.lat_lon_present?
      @params[:latitude] = @place.latitude
      @params[:longitude] = @place.longitude
    end
  end

  private

  def check_and_filter_place_attr
    if update_place_attributes? && !@place.reviewed
      @params.except!(*Place.column_names)
    end
  end

  def check_and_filter_descriptions
    translations_from_place_params.each do |t|
      if update_translation_attributes?(t) && !t.reviewed
        @params.except!("description_#{t.locale.to_s}")
      end
    end
  end

  def globalized_params
    @params.keys.select do |key, _value|
      Place.globalize_attribute_names.include? key.to_sym
    end
  end

  def locales_from_place_params
    globalized_params.map { |param| param.split('_').last }.flatten.select(&:present?)
  end

  def translations_from_place_params
    locales_from_place_params.map do |locale|
      @place.translations.find_by(locale: locale)
    end
  end

  def update_translation_attributes?(translation)
    @params.keys.include? "description_#{translation.locale.to_s}"
  end

  def update_place_attributes?
    @params.except(*globalized_params).any?
  end

end
