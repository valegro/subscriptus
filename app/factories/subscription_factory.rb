class SubscriptionFactory

  def self.build(offer, options = {})
    attributes         = options[:attributes] || {}
    term               = options[:term_id] ? OfferTerm.find(options[:term_id]) : offer.offer_terms.first
    included_gift_ids  = options[:included_gift_ids]
    optional_gift_id   = options[:optional_gift]
    source             = options[:source]

    # Build the subscription
    returning(Subscription.new(attributes)) do |subscription|
      subscription.state        = options[:init_state] || 'active'
      subscription.offer        = offer
      subscription.publication  = offer.publication
      subscription.source       = source

      # Check that there aren't any in included_gift_ids that aren't in available_included_gifts
      if included_gift_ids
        included_gift_ids.each do |gift_id|
          unless offer.available_included_gifts.map(&:id).include?(gift_id)
            raise Exceptions::GiftNotAvailable.new(gift_id)
          end
        end
      end
      # Included Gifts
      subscription.gifts << offer.available_included_gifts

      # Optional Gift
      if optional_gift_id
        unless offer.gifts.optional.in_stock.map(&:id).include?(optional_gift_id)
          raise Exceptions::GiftNotAvailable.new(optional_gift_id)
        end
        subscription.gifts << Gift.find(optional_gift_id) if optional_gift_id
      end

      # Set the offer term
      subscription.apply_term(term)
    end
  end
end
