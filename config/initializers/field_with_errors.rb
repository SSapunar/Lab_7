Rails.application.config.action_view.field_error_proc = Proc.new do |html_tag, instance|
  doc = Nokogiri::HTML::DocumentFragment.parse(html_tag)
  element = doc.at_css("input, textarea, select")

  if element
    element["class"] = [element["class"], "is-invalid"].compact.join(" ")
  end

  doc.to_s.html_safe
end