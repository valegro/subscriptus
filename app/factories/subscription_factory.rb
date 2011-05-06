class SubscriptionFactory
  attr_accessor :subscription
  attr_accessor :payment_option

  # ID in the subscription attributes will always be ignored
  # This is because of a bug in AR
  # If we perform a nested create inside a transaction, AR
  # will think we have a valid user ID from the created user
  # but if the subscription validation raises an error
  # and the transaction rolls back the User ID will no longer exist!

  def initialize(offer, options = {})
    @offer              = offer
    @attributes         = options[:attributes] || {}
    @term               = OfferTerm.find(options[:term_id]) rescue @offer.offer_terms.first
    @included_gift_ids  = options[:included_gift_ids]
    @optional_gift_id   = options[:optional_gift]
    @source             = options[:source] ? Source.find(options[:source]) : nil
    @concession         = options[:concession]
    @init_state         = options[:init_state]
    @attributes[:user_attributes].try(:delete, :id)
    @payment_attributes = options[:payment_attributes]
    @subscription       = Subscription.new(@attributes)
    @payment_option     = options[:payment_option] || 'credit_card'
  end

  def self.build(offer, options = {})
    factory = self.new(offer, options)
    factory.build
  end

  def update(subscription)
    @subscription = subscription
    build
  end

  # Build the subscription
  def build
    returning(@subscription) do |subscription|
      begin
        subscription.state        = set_state
        subscription.pending      = pending_what
        subscription.offer        = @offer
        subscription.publication  = @offer.publication

        if @term.blank? || @term.offer.blank? || @term.offer != @offer
          raise Exceptions::InvalidOfferTerm
        end

        # Build the Action
        action = SubscriptionAction.new do |action|
          action.offer_name   = @offer.name
          action.term_length  = @term.months
          action.source       = @source
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

        # TODO: Raise if price is >0 and no payment provided
        # Apply the action
        # TODO: Transactions?
        if subscription.active?
          action.build_payment(@payment_attributes)
          action.payment.amount = @term.price
          subscription.apply_action(action)
        end

        # TODO: Optimise this logic
        if subscription.pending?
          unless subscription.pending == :payment
            # Ensure we have a token
            credit_card = Payment.new(@payment_attributes).credit_card
            subscription.user.store_credit_card_on_gateway(credit_card)
            action.create_payment(@payment_attributes.merge(:payment_type => :token, :amount => @term.price))
          end
          subscription.pending_action = action
        end

        subscription.save!
      rescue ActiveRecord::RecordInvalid => e
        # Keep the subscription and any errors (they may not actually be for the subscription)
        raise Exceptions::Factory::InvalidException.new(subscription, e.record.errors)
      end
    end
  end

  private
    # TODO: What if we are pending student/concession AND direct debit!?
    def pending_what
      return nil unless set_state == 'pending'
      return 'payment' if payment_option == 'direct_debit'
      case @concession
        when 'student', :student       then 'student_verification'
        when 'concession', :concession then 'concession_verification'
      end
    end

    def set_state
      return @init_state unless @init_state.blank?
      if @concession.try(:to_s) == 'concession' && @subscription.user.try(:valid_concession_holder)
        'active'
      else
        ((@concession || @payment_option == 'direct_debit') ? 'pending' : 'active')
      end
    end
end
