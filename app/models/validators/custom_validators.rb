module CustomValidators
  class PhoneNumberFormatValidator < ActiveModel::EachValidator
    PHONE_REGEX = /\A((?![a-zA-Z]).){3,20}\z/

    def validate_each(record, attribute, value)
      unless value =~ PHONE_REGEX
        record.errors[attribute] << I18n.t('phone_number.formats.invalid')
      end
    end
  end

  class UrlFormatValidator < ActiveModel::EachValidator
    URL_REGEX = %r[\A​(https?:\/\/)?(www\.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)|(https?:\/\/)?(www\.)?(?!ww)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)\z]

    def validate_each(record, attribute, value)
      unless value =~ URL_REGEX
        record.errors[attribute] << I18n.t('url.formats.invalid')
      end
    end
  end

  class EmailFormatValidator < ActiveModel::EachValidator
    EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

    def validate_each(record, attribute, value)
      unless value =~ EMAIL_REGEX
        record.errors[attribute] << I18n.t('email_address.formats.invalid')
      end
    end
  end

  class IsBase64Validator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless base64?(value)
        record.errors[attribute] << I18n.t('not_base64_encoded')
      end
    end

    private

    def base64?(string)
      string.split('-').map do |token_part|
        token_part.is_a?(String) && Base64.encode64(Base64.decode64(token_part)) == token_part
      end.all?
    end
  end
end
