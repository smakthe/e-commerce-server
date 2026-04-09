# frozen_string_literal: true

class PaymentsController < ApplicationController
  # GET /orders/:order_id/payments
  def index
    render json: order.payments
  end

  # GET /orders/:order_id/payments/:id
  def show
    render json: payment
  end

  # POST /orders/:order_id/payments
  def create
    new_payment = order.payments.new(payment_params)

    if new_payment.save
      render json: new_payment, status: :created
    else
      render json: { errors: new_payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /orders/:order_id/payments/:id
  def update
    if payment.update(payment_params)
      render json: payment
    else
      render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /orders/:order_id/payments/:id
  def destroy
    payment.destroy
    render json: { message: "Payment deleted" }, status: :ok
  end

  private

  def order
    @order ||= current_user.orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end

  def payment
    @payment ||= order.payments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Payment not found" }, status: :not_found
  end

  def payment_params
    params.permit(:payment_date, :amount, :status)
  end
end
