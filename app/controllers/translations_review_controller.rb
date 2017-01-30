class TranslationsReviewController < ApplicationController
  before_action :require_login
  before_action :set_translation

  def review
    @reviewed_translation = reviewed_version(@unreviewed_translation)
    @other_translations_reviewed = other_reviewed_translations
  end

  def confirm
    if @unreviewed_translation.update(reviewed: true) && destroy_all_updates(@unreviewed_translation)
      flash[:success] = t('.translation_confirmed')
    end
    redirect_to places_review_index_url
  end

  def refuse
    if @unreviewed_translation.versions.last.reify.save && destroy_all_updates(@unreviewed_translation)
      flash[:success] = t('.translation_refused')
    end
    redirect_to places_review_index_url
  end

  private

  def current_language
    translation(params[:id]).locale
  end

  def translations_other_than(language)
    place_from_translation(params[:id]).translations.find_all { |t| t.locale != language }
  end

  def other_reviewed_translations
    translations_other_than(current_language).map { |t| reviewed_version(t) }.compact
  end

  def place_from_translation(id)
    Place.find { |p| p.translations.find_by(id: id) }
  end

  def translation(id)
    place_from_translation(id).translations.find(id)
  end

  def set_translation
    @unreviewed_translation = translation(params[:id])
  end

  def reviewed_version(t)
    t.versions[1].reify if t.versions.length > 1
  end

  def destroy_all_updates(obj)
    updates = obj.reload.versions.find_all { |v| v.event == 'update' }
    updates.each(&:destroy)
  end
end
