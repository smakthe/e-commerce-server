class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :order_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :newest_arrivals, -> { order(created_at: :desc).limit(4) }
  scope :best_selling, -> { order(total_sales_volume: :desc).limit(4) }
  scope :maximum_revenue, -> { order(total_revenue: :desc).limit(4) }

  def self.explore_data
    {
      newest_arrivals: newest_arrivals.to_a,
      best_selling: best_selling.to_a,
      maximum_revenue: maximum_revenue.to_a
    }
  end
end
