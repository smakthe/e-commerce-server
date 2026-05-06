# frozen_string_literal: true

class ProductsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :index, :show, :explore ]

  # GET /products/explore
  def explore
    render json: Product.explore_data
  end

  # GET /products
  def index
    if params[:search].present?
      # Use Elasticsearch if a search term is provided
      limit = params.fetch(:limit, 24).to_i
      offset = params.fetch(:offset, 0).to_i
      products = Product.search(
        query: {
          multi_match: {
            query: params[:search],
            fields: [ "name^3", "description" ]
          }
        },
        size: limit,
        from: offset
      ).records
    elsif params[:collection].present?
      limit = params.fetch(:limit, 24).to_i
      offset = params.fetch(:offset, 0).to_i
      case params[:collection]
      when "best_selling"
        products = Product.order(total_sales_volume: :desc).limit(limit).offset(offset)
      when "maximum_revenue"
        products = Product.order(total_revenue: :desc).limit(limit).offset(offset)
      else # newest_arrivals or default
        products = Product.order(created_at: :desc).limit(limit).offset(offset)
      end
    else
      # Standard ActiveRecord pull
      products = Product.order(created_at: :desc).limit(params.fetch(:limit, 25)).offset(params.fetch(:offset, 0))
    end

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
