class Product < ApplicationRecord
  has_many :order_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :best_selling, -> { joins(:order_items).group(:id).order(Arel.sql('SUM(order_items.quantity) DESC')).limit(5) }
  scope :most_expensive, -> { order(price: :desc).limit(5) }
  scope :maximum_revenue, -> { joins(:order_items).group(:id).order(Arel.sql('SUM(order_items.quantity * order_items.unit_price) DESC')).limit(5) }

  def self.explore_data
    Rails.cache.fetch('products/explore_data', expires_in: 12.hours) do
      {
        best_selling: best_selling.to_a,
        most_expensive: most_expensive.to_a,
        maximum_revenue: maximum_revenue.to_a
      }
    end
  end
end
