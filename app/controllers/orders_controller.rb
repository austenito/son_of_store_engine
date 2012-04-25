class OrdersController < ApplicationController
  before_filter :set_checking_out, :only => :new
  before_filter :authorize
  before_filter :admin_authorize, only: [:edit, :update]

  def index
    if params[:status_search] && current_user && current_user.admin?
      @orders = Order.where(status: params[:status_search])
    else
      @orders = Order.find_all_by_user_id(current_user.id)
    end
  end

  def show
    @order = Order.find(params[:id])
    @address = @order.address
  end

  def new
    if @cart.quantity == 0
      redirect_to '/',
      :alert => "You can't order something with nothing in your cart."
    else
      @order = Order.new
      @order.build_address
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    @order.update_status(params[:order][:status])
    redirect_to order_path(@order)
  end

  def create
    @order = current_user.orders.create(params[:order])
    @order.add_order_items_from(@cart)
    if @order.save_with_payment
      session[:cart_id] = Cart.create.id
      redirect_to @order, :notice => "Transaction Complete"
    else
      render :new
    end
  end

  private

  def set_checking_out
    session[:checking_out] = true    
  end
end
