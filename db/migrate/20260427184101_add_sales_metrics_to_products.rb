class AddSalesMetricsToProducts < ActiveRecord::Migration[8.1]
  def up
    add_column :products, :total_sales_volume, :integer, default: 0, null: false
    add_column :products, :total_revenue, :decimal, precision: 15, scale: 2, default: 0.0, null: false

    add_index :products, :total_sales_volume
    add_index :products, :total_revenue

    # Backfill the existing 100k products using raw fast Postgres update
    execute <<-SQL
      UPDATE products
      SET total_sales_volume = COALESCE(agg.volume, 0),
          total_revenue = COALESCE(agg.revenue, 0)
      FROM (
        SELECT product_id, 
               SUM(quantity) as volume, 
               SUM(quantity * unit_price) as revenue
        FROM order_items
        GROUP BY product_id
      ) as agg
      WHERE products.id = agg.product_id;
    SQL
  end

  def down
    remove_index :products, :total_sales_volume
    remove_index :products, :total_revenue
    
    remove_column :products, :total_sales_volume
    remove_column :products, :total_revenue
  end
end
