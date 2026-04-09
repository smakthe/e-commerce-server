# frozen_string_literal: true

class OrderItemsController < ApplicationController
  # GET /orders/:order_id/order_items
  def index
    render json: order.order_items.includes(:product)
                      .map { |oi| order_item_response(oi) }
  end

  # GET /orders/:order_id/order_items/:id
  def show
    render json: order_item_response(order_item)
  end

  # POST /orders/:order_id/order_items
  def create
    new_item = order.order_items.new(order_item_params)

    if new_item.save
      render json: order_item_response(new_item), status: :created
    else
      render json: { errors: new_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /orders/:order_id/order_items/:id
  def update
    if order_item.update(order_item_params)
      render json: order_item_response(order_item)
    else
      render json: { errors: order_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /orders/:order_id/order_items/:id
  def destroy
    order_item.destroy
    render json: { message: "Order item removed" }, status: :ok
  end

  private

  def order
    @order ||= current_user.orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end

  def order_item
    @order_item ||= order.order_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order item not found" }, status: :not_found
  end

  def order_item_params
    params.permit(:product_id, :quantity, :unit_price)
  end

  def order_item_response(oi)
    {
      id: oi.id,
      order_id: oi.order_id,
      product_id: oi.product_id,
      product_name: oi.product&.name,
      quantity: oi.quantity,
      unit_price: oi.unit_price
    }
  end
end
