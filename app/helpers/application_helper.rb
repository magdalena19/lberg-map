module ApplicationHelper
  def text_direction
    'rtl' if locale.to_s == 'ar'
  end

  def include_page_specific_javascript
    file = Rails.root.join('app', 'assets', 'javascripts', controller_name, action_name + '.js')
    javascript_include_tag("#{controller_name}/#{action_name}") if File.exist?(file)
  end

  def on_map?
    ['static_pages/map', 'static_pages/index'].include? "#{controller_name}/#{action_name}"
  end
end
