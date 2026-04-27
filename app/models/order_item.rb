class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_create :increment_product_metrics

  private

  def increment_product_metrics
    product.increment!(:total_sales_volume, quantity)
    product.increment!(:total_revenue, quantity * unit_price)
  end
end
