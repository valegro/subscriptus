class Admin::Reports::FreeTrialsController < Admin::ReportsController


  def new

  end

  def show
  
  end


  def index

    @pub_id = "1"

    @date_range = params[:date]

    @subscriptions = Subscription.find_by_sql("select * from subscription_log_entries l LEFT JOIN subscriptions s ON (s.id=l.subscription_id) where l.new_state='trial' AND LEFT(l.created_at,10)= '" + params[:date]+"'")

    @subscriptions_count = Array(Subscription.find_by_sql("select count(subscription_id) as count_total from subscription_log_entries s where s.new_state='trial' AND LEFT(s.created_at,10)= '" + params[:date]+"'"))
    @subscriptions_count = @subscriptions_count[0]['count_total'].to_s + " people signed up for a free trial in this period"

  end 

end
