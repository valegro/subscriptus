class Admin::Reports::SubscriptionsController < Admin::ReportsController

  #before_filter :set_daterange

  def new

  end

  def show

  end


  def index
    @pub_id = "1"

    @date_range = "All time"

    if params[:pending] == "false"
      @pending = false
      state_where = "state = 'active'"
    else
      @pending = true
      state_where = "(state = 'active' OR state = 'pending')"
    end


	@subscriptions = Array(Subscription.find_by_sql("select s.offer_id, o.name, z.count_renew, x.count_total from subscriptions s left join (select s.offer_id, count(1) as count_total from subscriptions s where " + state_where + "  AND s.publication_id=" + @pub_id + " group by s.offer_id) x on x.offer_id = s.offer_id left join (select s.offer_id, count(1) as count_renew from subscriptions s, subscription_actions a where s.id = a.subscription_id and a.renewal =1 and " + state_where + " AND s.publication_id=" + @pub_id + " and left(s.state_expires_at,10) = left(a.new_expires_at,10) group by s.offer_id) z on z.offer_id = s.offer_id left join offers o on (s.offer_id = o.id) where " + state_where + " AND s.publication_id=" + @pub_id + " group by s.offer_id order by o.name asc")).paginate(:page => params[:page])



    #@subscriptions = Array(Subscription.find_by_sql("select offer_id, offers.name, count(1) as number from subscriptions left join offers on (subscriptions.offer_id = offers.id) where "+state_where+"  AND subscriptions.publication_id="+@pub_id+" group by offer_id order by number desc")).paginate(:page => params[:page]) 

    @subscriptions_count = Subscription.count(:conditions => ["publication_id = ? AND " + state_where, @pub_id])

  end 

  def set_daterange
    respond_to do |format|
      unless request.post?
        format.js {
          render :update do |page|
            page.insert_html :bottom, 'content', :partial => 'set_daterange_dialog'
            page['set-daterange-dialog'].dialog('open')
          end
        }
      else

	start_date = params[:set_daterange]["start_date(1i)"] + "-" + params[:set_daterange]["start_date(2i)"] + "-" + params[:set_daterange]["start_date(3i)"] 
	end_date = params[:set_daterange]["end_date(1i)"] + "-" + params[:set_daterange]["end_date(2i)"] + "-" + params[:set_daterange]["end_date(3i)"]
 	date_where = " AND ( (state_updated_at >= '" + start_date + "' AND state_updated_at <= '" + end_date  + "') OR (s.created_at >= '" + start_date + "' AND s.created_at <= '" + end_date  + "') ) "
	date_where_no_alias = " AND ( (state_updated_at >= '" + start_date + "' AND state_updated_at <= '" + end_date  + "') OR (subscriptions.created_at >= '" + start_date + "' AND subscriptions.created_at <= '" + end_date  + "') ) "


	@date_range = Date.strptime(start_date, "%Y-%m-%d").strftime("%d/%m/%Y") + " to " + Date.strptime(end_date, "%Y-%m-%d").strftime("%d/%m/%Y")

    	@pub_id = "1"

    	if params[:set_daterange]["hdn_pending"] == "false"
      	  @pending = false
      	  state_where = "state = 'active'"
    	else
      	  @pending = true
      	  state_where = "(state = 'active' OR state = 'pending')"
    	end

    	#@subscriptions = Array(Subscription.find_by_sql("select offer_id, offers.name, count(1) as number from subscriptions left join offers on (subscriptions.offer_id = offers.id) where " + state_where + date_where + "  AND subscriptions.publication_id="+@pub_id+" group by offer_id order by number desc")).paginate(:page => params[:page]) 

	# no pagination because that uses 'get' and the dialog only allows date select with POST
	@subscriptions = Array(Subscription.find_by_sql("select s.offer_id, o.name, z.count_renew, x.count_total from subscriptions s left join (select s.offer_id, count(1) as count_total from subscriptions s where " + state_where + date_where + "  AND s.publication_id=" + @pub_id + " group by s.offer_id) x on x.offer_id = s.offer_id left join (select s.offer_id, count(1) as count_renew from subscriptions s, subscription_actions a where s.id = a.subscription_id and a.renewal =1 and " + state_where + date_where + " AND s.publication_id=" + @pub_id + " and left(s.state_expires_at,10) = left(a.new_expires_at,10) group by s.offer_id) z on z.offer_id = s.offer_id left join offers o on (s.offer_id = o.id) where " + state_where + date_where + " AND s.publication_id=" + @pub_id + " group by s.offer_id order by o.name asc"))

	@subscriptions_count = Subscription.count(:conditions => ["publication_id = ? AND " + state_where + date_where_no_alias, @pub_id])

        format.html { 
	  render :action => :index
        }
      end
    end
  end

end
