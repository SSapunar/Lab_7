ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.gsub(/class="/, 'class="is-invalid ').html_safe
end