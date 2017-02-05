class NullTranslator
  def can_translate?(text)
    false
  end

  def translate(text:, from:, to:)
    # TODO translate that...
    'No translation possible'
  end
end
