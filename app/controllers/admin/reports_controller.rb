class Admin::ReportsController < AdminController
  layout 'admin/reports'


  def index
    @subscriptions = Subscription.all
put "subs"
p @subscriptions
  end
end
