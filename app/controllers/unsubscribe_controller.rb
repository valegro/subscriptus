class UnsubscribeController < ApplicationController
  layout 'signup'

  before_filter :load_user, :except => :no_user
  before_filter :load_publication

  rescue_from ActiveRecord::RecordInvalid do
    # Already unsubscribed
    flash[:error] = "You have already unsubscribed from one or more subscriptions"
    render :action => :show
  end

  rescue_from ActiveRecord::RecordNotFound do
    # Can't find matching user account
    render :action => 'no_user'
  end

  def show
  end

  def create
    subs = Subscription.find(params[:subscriptions])
    @user = subs.first.try(:user)
    subs.each do |sub|
      sub.unsubscribe!
    end
  end

  private
    def load_user
      # TODO: Take the email address too?
      @user = User.find(params[:user_id])
      @subscriptions = @user.subscriptions.not_unsubscribed
    end
    
    def load_publication
      @publication = Publication.for_domain(current_domain).first
    end
end
