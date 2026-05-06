# frozen_string_literal: true

class CheckoutController < ApplicationController
  # POST /checkout
  def create
    ApplicationRecord.transaction do
      # 1. Create the order
      order = current_user.orders.create!(
        order_date:   Time.current,
        status:       "pending",
        total_amount: checkout_params[:total_amount]
      )

      # 2. Create each order item — triggers stock check + product metric update
      checkout_params[:items].each do |item|
        order.order_items.create!(
          product_id: item[:product_id],
          quantity:   item[:quantity],
          unit_price: item[:unit_price]
        )
      end

      # 3. Record the payment
      order.payments.create!(
        payment_date: Time.current,
        amount:       checkout_params[:total_amount],
        status:       "completed"
      )

      render json: {
        message:  "Order placed successfully",
        order_id: order.id
      }, status: :created
    end

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  private

  def checkout_params
    params.permit(:total_amount, items: [ :product_id, :quantity, :unit_price ])
  end
end
