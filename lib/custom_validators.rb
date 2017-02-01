module CustomValidators
  class PhoneNumberFormatValidator < ActiveModel::EachValidator
    PHONE_REGEX = /\A((?![a-zA-Z]).){3,20}\z/

    def validate_each(record, attribute, value)
      unless value =~ PHONE_REGEX
        record.errors[attribute] << 'Invalid phone number'
      end
    end
  end

  class GermanPostalCodeValidator < ActiveModel::EachValidator
    POSTAL_CODE_REGEX = /\A\d{5}\z/

    def validate_each(record, attribute, value)
      unless value =~ POSTAL_CODE_REGEX
        record.errors[attribute] << 'supply valid postal code (5 digits)'
      end
    end
  end

  class UrlFormatValidator < ActiveModel::EachValidator
    URL_REGEX = %r[\A​(https?:\/\/)?(www\.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)|(https?:\/\/)?(www\.)?(?!ww)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)\z]

    def validate_each(record, attribute, value)
      unless value =~ URL_REGEX
        record.errors[attribute] << 'Invalid URL'
      end
    end
  end

  class EmailFormatValidator < ActiveModel::EachValidator
    EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

    def validate_each(record, attribute, value)
      unless value =~ EMAIL_REGEX
        record.errors[attribute] << 'This cannot be a valid email address'
      end
    end
  end
end
