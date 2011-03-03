class SubscribeFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::TagHelper

  %w(text_field password_field select enum_select country_select date_select).each do |method_id|
    define_method(method_id) do |*args|
      wrapping(*args) do
        super
      end
    end
  end

  def check_box(*args)
    options = args.extract_options!
    method = args.first
    returning(super) do |str|
      str << label(method, options[:label])
    end
  end

  protected
    def wrapping(*args, &block)
      options = args.extract_options!
      method = args.first
      label = options.fetch(:label, method.to_s.humanize) << ":"
      label << "<span class='mandatory'>*</span>" if options[:required]
      returning("") do |s|
        s << "<div class='form-row'>"
        s << yield
        s << label(method, label)
        s << "<span class='instructions'>#{options[:help]}</span>" if options.has_key?(:help)
        s << "</div>"
      end
    end
end
