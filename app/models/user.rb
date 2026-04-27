class User < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy
  has_many :order_items, through: :orders

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,   length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def full_name
    "#{first_name} #{last_name}"
  end

  def dashboard_stats
    total = orders.count
    amount = orders.sum(:total_amount)
    
    {
      total_orders: total,
      total_amount: amount,
      average_order_value: total > 0 ? (amount.to_f / total).round(2) : 0,
      daily_spend: daily_spend_stats,
      status_distribution: orders.group(:status).count,
      top_products: top_purchased_products
    }
  end

  private

  def daily_spend_stats
    orders.group("DATE(order_date)").sum(:total_amount)
          .map { |date, amount| { date: date, amount: amount } }
          .sort_by { |hash| hash[:date].to_s }
  end

  def top_purchased_products
    order_items.joins(:product)
               .group("products.id", "products.name")
               .order(Arel.sql("SUM(order_items.quantity) DESC"))
               .limit(5)
               .pluck("products.name", Arel.sql("SUM(order_items.quantity)"))
               .map { |name, qty| { product_name: name, total_quantity: qty } }
  end
end