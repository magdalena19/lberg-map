class NullTranslator
  def translate(text:, from:, to:)
    # TODO translate that...
    'No translation possible'
  end

  def languages_available?(lang_codes)
    false
  end

  def char_balance_sufficient?
    true
  end
end
