module Sanitization
  def sanitize(html)
    Rails::Html::WhiteListSanitizer.new.sanitize(
    html,
    tags: %w[br u i b li ul ol hr font a],
    attributes: %w[align color size href]
    )
  end
end
