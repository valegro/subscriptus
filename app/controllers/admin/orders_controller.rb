class Admin::OrdersController < AdminController
  layout 'admin/orders'

  def index
    @orders = Order.pending.oldest_first.paginate(:page => params[:page] || 1, :include => :gifts)
  end

  def completed
    @orders = Order.completed.newest_first.paginate(:page => params[:page] || 1, :include => :gifts)
  end

  def delayed
    @orders = Order.delayed.oldest_first.paginate(:page => params[:page] || 1, :include => :gifts)
  end
  
  def show
    @order = Order.find(params[:id])
    # TODO: Raise error on missing user?
    @user = @order.user || User.build(:name => 'Missing User')
  end
  
end
