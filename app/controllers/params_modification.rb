module ParamsModification
  module Place
    class << self
      attr_accessor :params
      attr_reader :klass

      def modify(place_params:, place: nil)
        @params = place_params
        @place = place
        @klass = @place.class

        if @place.present?
          check_and_filter_place_attr
          check_and_filter_descriptions
        end

        modify_category_params
        modify_event_params
        modify_geocoords_params
        
        return params
      end

      private

      def modify_category_params
        if @params[:categories]
          category_param = @params[:categories].split(/,|;/).map(&:strip).sort || []
          @params[:categories] = category_param.reject(&:empty?).join(',')
        end
      end

      def modify_event_params
        if @params[:event] == "true"
          @params[:event] = true
          date = @params[:start_date].split(' - ').reverse
          @params[:start_date] = date.pop.to_datetime
          @params[:end_date] = date.any? ? date.pop.to_datetime : nil
        else
          @params[:event] = false
          @params[:start_date] = nil
          @params[:end_date] = nil
        end
      end

      def modify_geocoords_params
        if @place && @place.lat_lon_present?
          @params[:latitude] = @place.latitude
          @params[:longitude] = @place.longitude
        end
      end

      def check_and_filter_place_attr
        if update_place_attributes? && !@place.reviewed
          @params.except!(*klass.column_names)
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
          klass.globalize_attribute_names.include? key.to_sym
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
  end
end
