class SubscriptionFactory
  attr_accessor :subscription

  # ID in the subscription attributes will always be ignored
  # This is because of a bug in AR
  # If we perform a nested create inside a transaction, AR
  # will think we have a valid user ID from the created user
  # but if the subscription validation raises an error
  # and the transaction rolls back the User ID will no longer exist!

  def initialize(offer, options = {})
    @offer              = offer
    @attributes         = options[:attributes] || {}
    @term               = options[:term_id] ? OfferTerm.find(options[:term_id]) : offer.offer_terms.first
    @included_gift_ids  = options[:included_gift_ids]
    @optional_gift_id   = options[:optional_gift]
    @source             = options[:source]
    @concession         = options[:concession]
    @init_state         = options[:init_state]
    @attributes[:user_attributes].try(:delete, :id)
    @subscription       = Subscription.new(@attributes)
  end

  def self.build(offer, options = {})
    factory = self.new(offer, options)
    factory.build
  end

  # Build the subscription
  def build
    returning(@subscription) do |subscription|
      subscription.state        = @init_state || (@concession ? 'pending' : 'active')
      subscription.pending      = pending_what
      subscription.offer        = @offer
      subscription.publication  = @offer.publication
      subscription.source       = @source

      if @term.blank? || @term.offer.blank? || @term.offer != @offer
        raise Exceptions::InvalidOfferTerm
      end

      # Build the Action
      # TODO: Do we move the action build into a sep method?
      action = SubscriptionAction.new do |action|
        action.offer_name   = @offer.name
        action.price        = @term.price
        action.term_length  = @term.months
      end

      # Check that there aren't any in included_gift_ids that aren't in available_included_gifts
      unless @included_gift_ids.blank?
        @included_gift_ids.each do |gift_id|
          unless @offer.available_included_gifts.map(&:id).include?(gift_id)
            raise Exceptions::GiftNotAvailable.new(gift_id)
          end
        end
      end
      # Included Gifts
      action.gifts << @offer.available_included_gifts

      # Optional Gift
      if @optional_gift_id
        unless @offer.gifts.optional.in_stock.map(&:id).include?(@optional_gift_id.to_i)
          raise Exceptions::GiftNotAvailable.new(@optional_gift_id)
        end
        action.gifts << Gift.find(@optional_gift_id) if @optional_gift_id
      end

      # Apply the action
      # TODO: Transactions?
      if subscription.active?
        subscription.apply_action(action)
        # TODO: Payment!
      end

      # TODO: Optimise this logic
      if subscription.pending?
        subscription.pending_action = action
      end
    end
  end

  # TODO: Does verify go here? Or is it on the subscription? How is the action applied?

  private
    def pending_what
      case @concession
        when 'student', :student       then 'student_verification'
        when 'concession', :concession then 'concession_verification'
      end
    end
end
