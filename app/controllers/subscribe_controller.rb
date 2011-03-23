class SubscribeController < ApplicationController
  layout 'signup'
  before_filter :load_offer
  before_filter :load_gifts

  def new
    source = (params[:source_id] && params[:source_id] != 'null') ? Source.find(params[:source_id]) : nil
    @subscription = Subscription.new
    @subscription.offer = @offer
    @subscription.source = source
    if params[:delivered_to]
      # TODO: Spec
      @user = User.find_by_email(params[:delivered_to])
      if @user && @user.has_active_subscriptions?
        @subscription.user = @user
      end
    end
    @user ||= @subscription.build_user(:title => 'Mr', :state => :act)
    @subscription.payments.build
  end


    # TODO: We should be doing something like this
    # @subscription = Subscription.new_from_offer(offer, term, optional_gift, included_gifts(ids), params...)
    # But need to specify term chosen, optional gift chosen and the list of included gifts that were offered
    # Then the form doesn't need to worry about fields_for for the gifts just optional_gifts and included_gifts as arrays
    # Get rid of accepts_nested for subscription_gifts
  # TODO: Use the factory
  # TODO: Handle any of the exceptions that the factory might raise
  #
  def create
    @subscription = Subscription.new(params[:subscription])
    #@subscription = Subscription.from_offer(@offer, {
    #  :term_id => params[:offer_term],
    #  :optional_gift => 1,
    #  :included_gifts => @included_gifts,
    #  :attributes => params[:subscription]
    #})
    @user = @subscription.user

    # Set to active because we are taking payment
    @subscription.state = 'active'
    @subscription.use_offer(@offer, @term)

    if @subscription.save_in_transaction
      redirect_to :action => :thanks
    else
      render :action => :new
    end
  end

  private
    def load_offer
      @offer = params[:offer_id] ? Offer.find(params[:offer_id]) : Offer.first
    end

    def load_gifts
      @included_gifts = @offer.gifts.in_stock.included
      if @offer.gifts.in_stock.optional.size == 1
        @included_gifts.concat(@offer.gifts.in_stock.optional)
        @optional_gifts = []
      else
        @optional_gifts = @offer.gifts.in_stock.optional
      end
    end
end
