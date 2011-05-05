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
end
