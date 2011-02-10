class Admin::OrdersController < AdminController
  layout 'admin/orders'
  
  before_filter :find_order, :only => [:show, :fulfill, :delay]

  def index
    @orders = Order.pending.oldest_first.paginate(:page => params[:page] || 1, :include => :gifts)
    @order_scope = :pending
  end

  def completed
    @orders = Order.completed.newest_first.paginate(:page => params[:page] || 1, :include => :gifts)
    @order_scope = :completed
  end

  def delayed
    @orders = Order.delayed.oldest_first.paginate(:page => params[:page] || 1, :include => :gifts)
    @order_scope = :delayed
  end
  
  def show
    # TODO: Raise error on missing user?
    @user = @order.user || User.build(:name => 'Missing User')
  end
  
  def fulfill
    @order.fulfill!
    order_scope = params[:order_scope]
    order_scope = :pending unless %w(pending completed delayed).include?(order_scope)
    @orders = Order.send(order_scope).oldest_first.paginate(:page => params[:page] || 1, :include => :gifts)
    respond_to do |wants|
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
end
