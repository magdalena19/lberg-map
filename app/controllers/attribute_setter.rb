module AttributeSetter
  module Place
    class << self
      def set_attributes_after_update(place:, params:, privileged:)
        @place = place
        @params = params
        @privileged = privileged
        update_translations_reviewed_flag if translation_attributes_changed?
        update_place_reviewed_flag if place_attributes_changed?
        place.destroy_all_updates if privileged
      end

      def set_attributes_after_create(place:, params:, privileged:)
        @place = place
        @params = params
        @privileged = privileged
        set_inital_reviewed_flags
      end

      private

      def update_translations_reviewed_flag
        locales_from_place_params.each do |locale|
          translation = @place.translations.find_by_locale(locale)
          translation.update_attributes(reviewed: @privileged)
          @place.destroy_all_updates(translation) if @privileged
        end
      end

      def place_attributes_changed?
        @place.previous_changes.except("description", "created_at", "updated_at").any?
      end

      def translation_attributes_changed?
        @place.translations.map { |t| t.previous_changes.any? }.any?
      end

      # Find if params hash contains translation related key
      def globalized_params
        @params.keys.select do |key, _value|
          @place.class.globalize_attribute_names.include? key.to_sym
        end
      end

      def locales_from_place_params
        globalized_params.map { |param| param.split('_').last }.flatten.select(&:present?)
      end

      # Update reviewed flags depending on login status
      def update_place_reviewed_flag
        @place.update_attributes(reviewed: @privileged)
      end

      # Set reviewed flags depending on login status during creation
      def set_inital_reviewed_flags
        update_place_reviewed_flag
        @place.destroy_all_updates
        @place.translations.each do |translation|
          translation.update!(reviewed: @privileged)
        end
      end
    end
  end
end
