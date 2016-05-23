module StaticPagesHelper
  def text_direction
    'rtl' if locale.to_s == 'ar'
  end
end
