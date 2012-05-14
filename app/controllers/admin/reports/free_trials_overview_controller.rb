class Admin::Reports::FreeTrialsOverviewController < Admin::ReportsController


  def new

  end

  def show

  end


  def index
    @pub_id = "1"

    @date_range = "All <strong>current</strong> Free Trialers"

    @subscriptions = Array(Subscription.find_by_sql("select left(state_updated_at, 10) as date, count(*) as count_total from subscriptions s where state_updated_at !='' and s.state='trial' AND s.publication_id=" + @pub_id + " group by left(state_updated_at,10)" )) 

    @subscriptions_count = Subscription.count(:conditions => ["publication_id = ? AND state = ? AND state_updated_at !='' " , @pub_id, "trial"])

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
 	date_where = " AND (created_at >= '" + start_date + "' AND created_at <= '" + end_date  + "') "

	@date_range = Date.strptime(start_date, "%Y-%m-%d").strftime("%d/%m/%Y") + " to " + Date.strptime(end_date, "%Y-%m-%d").strftime("%d/%m/%Y")

    	@pub_id = "1"

	@subscriptions = Array(Subscription.find_by_sql("select left(created_at, 10) as date, count(subscription_id) as count_total from subscription_log_entries s where s.new_state='trial' " + date_where + " group by left(created_at,10)" ))

        @subscriptions_count = Array(Subscription.find_by_sql("select count(subscription_id) as count_total from subscription_log_entries s where s.new_state='trial' " + date_where))
        @subscriptions_count = @subscriptions_count[0]['count_total'].to_s + " people signed up for a free trial in this period"

        format.html { 
	  render :action => :index
        }
      end
    end
  end

end
