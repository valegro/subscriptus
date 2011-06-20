class Webhooks::UnbouncesController < ApplicationController
   protect_from_forgery :except => :create

  rescue_from Exceptions::AlreadyHadTrial do
    render :json => { :success => false, :message => "Trial within last 12 months" }
  end

  def create
    if params['data.json']
      @json = JSON.parse(params['data.json'])
      @publication = Publication.find(params[:publication_id])
      @referrer = params[:page_url]
      options = @json.delete('options')
      weekender = options && options.any? { |s| /weekender/i === s }
      solus = options && options.any? { |s| /advertisers/i === s }
      @attributes = @json.each { |k, v| @json[k] = v.to_s }.symbolize_keys
      @attributes[:options] = { :weekender => weekender, :solus => solus }
      @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @attributes)
    end
    render :json => { :success => true }
  end
end
