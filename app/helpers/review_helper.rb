module ReviewHelper
  def diff_to_reviewed
    if @reviewed_translation
      Differ.diff_by_word(@unreviewed_translation.description, @reviewed_translation.description)
    else
      @unreviewed_translation.description.html_safe
    end
  end
end
