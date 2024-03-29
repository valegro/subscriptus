class Admin::OrdersController < AdminController
  layout 'admin/orders'
  
  before_filter :find_order, :only => [:show, :fulfill, :postpone]
  
  def index
    find_orders(:pending)
    respond_to do |wants|
      wants.html
      wants.csv {
        csv_response_headers('pending_orders.csv')
        @orders = Order.pending.newest_first
        render :partial => "orders", :locals => {:orders => @orders}
      }
    end
  end

  def completed
    find_orders(:completed)
  end

  def approve
	p params
	if params["commit"] == "Approve Selected"
		params["orders"].each { |order| Order.find(order).fulfill }
	elsif params["commit"] == "Approve All"  
		Order.pending.each { |order| order.fulfill }
	end 
	redirect_to admin_orders_path;
  end 

  def delayed
    find_orders(:delayed)
  end
  
  def show
    # TODO: Raise error on missing user?
    @user = @order.user
    @subscription = @order.subscription || Subscription::Archive.find_by_id(@order.subscription_id)
    @offer = @subscription.try(:offer)
    flash[:error] = 'The user associated with this order could not be found' unless @user
  end
  
  def fulfill
    @order.fulfill!
    
    find_orders(params[:order_scope])
    
    respond_to do |wants|
      wants.html {
        redirect_to admin_order_path(@order)
      }
      wants.js {
        render :update do |page|
          page.replace :orders_table, :partial => 'orders', :locals => {:orders => @orders}
        end
      }
    end
  end
  
  def postpone
    @order.postpone!
    find_orders(params[:order_scope])
    respond_to do |wants|
      wants.html {
        redirect_to admin_order_path(@order)
      }
      wants.js {
        render :update do |page|
          page.replace :orders_table, :partial => 'orders', :locals => {:orders => @orders}
        end
      }
    end
  end
  
  private
  def find_order
    @order = Order.find(params[:id])
  end
  
  def find_orders(order_scope)
    @order_scope = order_scope.to_s
    @order_scope = 'pending' unless %w(pending completed delayed).include?(@order_scope)
    
    ordering = @order_scope == 'completed' ? :newest_first : :oldest_first
    @orders = Order.send(@order_scope).send(ordering).paginate(:page => params[:page] || 1, :include => :gifts)
  end
end
