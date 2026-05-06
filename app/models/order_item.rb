class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_create :check_stock_availability
  after_create  :update_product_metrics

  private

  def check_stock_availability
    unless product.stock >= quantity
      errors.add(:quantity, "exceeds available stock (#{product.stock} units available)")
      throw :abort
    end
  end

  def update_product_metrics
    product.with_lock do
      product.total_sales_volume += quantity
      product.total_revenue      += quantity * unit_price
      product.stock              -= quantity
      product.save!
    end
  end
end
