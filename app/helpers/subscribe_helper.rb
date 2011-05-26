module SubscribeHelper
  
  def describe_offer_term(ot)
    return "" unless ot
    if ot.expires?
      "#{pluralize(ot.months, 'month')} for #{number_to_currency_with_free(ot.price)}"
    else
      "Forever for #{number_to_currency_with_free(ot.price)}"
    end
  end

  def gift_label(gift)
    returning(image_tag(gift.gift_image.url(:thumb))) do |str|
      str << content_tag(:span, h(gift.name), :class => "gift-title")
      str << content_tag(:span, h(gift.description))
    end
  end

  def tab_path(tab)
    url_for(:tab => tab, :offer_id => @offer.try(:id), :source_id => @source.try(:id))
  end
  
  def error_messages(errors)
    return nil if errors.blank?
    content_tag(:ul) do
      errors.full_messages.map do |message|
        content_tag(:li, message.inspect)
      end
    end
  end

  def get_subscribe_submit_path(offer, source, tab, renewing = false, _for = nil)
    if renewing
      options = { :offer_id => offer.id, :source_id => source.try(:id), :tab => tab }
      options[:for] = _for unless _for.blank?
      renew_path(options)
    else
      subscribe_path(:offer_id => offer.id, :source_id => source.try(:id), :tab => tab)
    end
  end
end
