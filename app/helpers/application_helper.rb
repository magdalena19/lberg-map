module ApplicationHelper
  def text_direction
    'rtl' if locale.to_s == 'ar'
  end

  def include_page_specific_javascript
    file = Rails.root.join('app', 'assets', 'javascripts', controller_name, action_name + '.js')
    javascript_include_tag("#{controller_name}/#{action_name}") if File.exist?(file)
  end

  def on_map?
    'maps/show' == "#{controller_name}/#{action_name}" || 'choose_locale' == action_name
  end
end
