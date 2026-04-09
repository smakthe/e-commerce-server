# frozen_string_literal: true

class OrdersController < ApplicationController
  # GET /orders — only the current user's orders
  def index
    orders = current_user.orders.order(order_date: :desc)
    render json: orders.map { |o| order_response(o) }
  end

  # GET /orders/:id
  def show
    render json: order_response(order)
  end

  # POST /orders
  def create
    new_order = current_user.orders.new(order_params)

    if new_order.save
      render json: order_response(new_order), status: :created
    else
      render json: { errors: new_order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /orders/:id
  def update
    if order.update(order_params)
      render json: order_response(order)
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /orders/:id
  def destroy
    order.destroy
    render json: { message: "Order deleted successfully" }, status: :ok
  end

  private

  # Authorization: users can only access their own orders
  def order
    @order ||= current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end

  def order_params
    params.permit(:order_date, :status, :total_amount)
  end

  def order_response(order)
    {
      id: order.id,
      user_id: order.user_id,
      order_date: order.order_date,
      status: order.status,
      total_amount: order.total_amount,
      items_count: order.order_items.size
    }
  end
end
