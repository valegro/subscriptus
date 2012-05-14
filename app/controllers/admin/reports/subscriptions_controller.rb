class Admin::Reports::SubscriptionsController < Admin::ReportsController

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

    @subscriptions = Array(Subscription.find_by_sql("select s.offer_id, o.name as offer_name, IFNULL(z.count_renew,0) as count_renew, IFNULL(y.count_new,0)+IFNULL(z.count_renew,0) as count_total, IFNULL(y.count_new,0) as count_new from subscriptions s left join (select s.offer_id, count(distinct s.id) as count_renew from subscriptions s, subscription_actions a where s.id = a.subscription_id and a.renewal =1 and " + state_where + " AND s.publication_id=" + @pub_id + " group by s.offer_id) z on z.offer_id = s.offer_id left join (select s.offer_id, count(distinct s.id) as count_new from subscriptions s, subscription_actions a where s.id = a.subscription_id and a.renewal =0 and " + state_where + " AND s.publication_id=" + @pub_id + " group by s.offer_id) y on y.offer_id = s.offer_id left join offers o on (s.offer_id = o.id) where " + state_where + " AND s.publication_id=" + @pub_id + " AND IFNULL(y.count_new,0)+IFNULL(z.count_renew,0)>0 group by s.offer_id order by o.name asc")).paginate(:page => params[:page])

    @subscriptions_count = Subscription.count(:conditions => ["publication_id = ? AND " + state_where, @pub_id]).to_s()  + " people are currenty subscribed"

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
 	date_where = " AND applied_at >= '" + start_date + "' AND a.applied_at <= '" + end_date  + "'"

	@date_range = Date.strptime(start_date, "%Y-%m-%d").strftime("%d/%m/%Y") + " to " + Date.strptime(end_date, "%Y-%m-%d").strftime("%d/%m/%Y")

    	@pub_id = "1"
	
	@pending = false


	# no pagination because that uses 'get' and the dialog only allows date select with POST
	@subscriptions = Array(Subscription.find_by_sql("select count(distinct subscription_id) as count_total, z.count_renew, y.count_new, a.offer_name from subscriptions s ,subscription_actions a left join (select a.offer_name, count(distinct subscription_id) as count_renew from subscription_actions a, subscriptions s where s.id = a.subscription_id and a.term_length > 0 and s.publication_id=1 AND a.renewal = 1 "+date_where+" group by a.offer_name) z on z.offer_name = a.offer_name left join (select a.offer_name, count(distinct subscription_id) as count_new from subscription_actions a, subscriptions s where s.id = a.subscription_id and a.term_length > 0 and s.publication_id=1 AND a.renewal = 0 "+date_where+" group by a.offer_name) y on y.offer_name = a.offer_name where s.id = a.subscription_id and a.term_length > 0 and s.publication_id=1 "+date_where+" group by a.offer_name"))

	@subscriptions_count = Array(Subscription.find_by_sql("select count(distinct subscription_id) as count_total from subscription_actions a, subscriptions s where s.id = a.subscription_id and a.term_length > 0 and s.publication_id=1 " + date_where))
	@subscriptions_count = @subscriptions_count[0]['count_total'].to_s + " people subscribed in this period"

        format.html { 
	  render :action => :index
        }
      end
    end
  end

end
