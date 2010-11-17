module SubscribeHelper
  
  def describe_offer_term(ot)
    return "" unless ot
    if ot.expires?
      "#{pluralize(ot, 'month')} for #{number_to_currency_with_free(ot.price)}"
    else
      "Forever for #{number_to_currency_with_free(ot.price)}"
    end
  end
end
