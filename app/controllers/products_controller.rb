# frozen_string_literal: true

class ProductsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :index, :show, :explore ]

  # GET /products/explore
  def explore
    render json: Product.explore_data
  end

  # GET /products
  def index
    products = Product.all
    products = products.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    products = products.order(created_at: :desc).limit(params.fetch(:limit, 25)).offset(params.fetch(:offset, 0))
    render json: products
  end

  # GET /products/:id
  def show
    render json: product
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  # POST /products
  def create
    new_product = Product.new(product_params)

    if new_product.save
      render json: new_product, status: :created
    else
      render json: { errors: new_product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /products/:id
  def update
    if product.update(product_params)
      render json: product
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  # DELETE /products/:id
  def destroy
    product.destroy
    render json: { message: "Product deleted successfully" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  private

  def product
    @product ||= Product.find(params[:id])
  end

  def product_params
    params.permit(:name, :description, :price, :stock)
  end
end
