class Webhooks::UnbouncesController < ApplicationController
   protect_from_forgery :except => :create

   def create
     if params['data.json']
       @json = JSON.parse(params['data.json'])
       @publication = Publication.find(params[:publication_id])
       @referrer = params[:page_url]
       @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @json)
     end
     render :text => "OK"
   end
end
