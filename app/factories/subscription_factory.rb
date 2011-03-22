class SubscriptionFactory

  def self.build(offer, options = {})
    attributes         = options[:attributes] || {}
    term               = options[:term_id] ? OfferTerm.find(options[:term_id]) : offer.offer_terms.first
    included_gift_ids  = options[:included_gift_ids]
    optional_gift_id   = options[:optional_gift_id]

    # Build the subscription
    returning(Subscription.new(attributes)) do |subscription|
      subscription.offer = offer
      subscription.publication = offer.publication
      subscription.price = term.price

      # Check that there aren't any in included_gift_ids that aren't in available_included_gifts
      if included_gift_ids
        unless offer.available_included_gifts.map(&:id).sort == included_gift_ids
          raise "Gift Not Available"
        end
      end
      # Included Gifts
      subscription.gifts << offer.available_included_gifts

      # Optional Gift
      if optional_gift_id
        raise "Gift Not Available" unless offer.gifts.optional.in_stock.map(&:id).include?(optional_gift_id)
        subscription.gifts << Gift.find(optional_gift_id) if optional_gift_id
      end

      # Set the payment price
      subscription.payments.last.try(:amount=, subscription.price)
      subscription.increment_expires_at(term)
    end
  end
end
