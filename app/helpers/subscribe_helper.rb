module SubscribeHelper
  
  def wizardly_submit
    @@wizardly_submit ||= {}
    step_id = "#{controller_name}_#{@step}".to_sym
    unless @@wizardly_submit[step_id]
      buttons = @wizard.pages[@step].buttons
      @@wizardly_submit[step_id] = buttons.inject(StringIO.new) do |io, button|
        io << submit_tag(button.name, :name=>button.id.to_s)
      end.string
    end
    @@wizardly_submit[step_id]
  end
  
  def wizardly_image_submit(asset_dir = nil, opts = {})
    @@wizardly_image_submit ||={}
    step_id = "#{controller_name}_#{@step}".to_sym
    unless @@wizardly_image_submit[step_id]
      asset_dir = asset_dir ? "#{asset_dir}/".squeeze("/").sub(/^\//,'') : "wizardly/"
      buttons = @wizard.pages[@step].buttons
      @@wizardly_image_submit[step_id] = buttons.inject(StringIO.new) do |io, button|
        opts[:value] = button.name
        opts[:name] = button.id.to_s
        io << image_submit_tag("#{asset_dir}#{button.id}.png", opts)
      end.string
    end
    @@wizardly_image_submit[step_id]
  end

  def describe_offer_term(ot)
    return "" unless ot
    if ot.expires?
      "#{pluralize(ot, 'month')} for #{number_to_currency_with_free(ot.price)}"
    else
      "Forever for #{number_to_currency_with_free(ot.price)}"
    end
  end
end
