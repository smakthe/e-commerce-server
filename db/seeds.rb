# frozen_string_literal: true

require "bcrypt"
require "securerandom"
require "etc"

puts "Starting Ultra-Fast Parallel Seeding 🚀"
start_time = Time.now

# Configuration
NUM_USERS       = 10_000
NUM_PRODUCTS    = 100_000
NUM_ORDERS      = 1_000_000

# Clean slate
puts "Truncating tables..."
ActiveRecord::Base.connection.execute("TRUNCATE TABLE users, products, orders, order_items, payments RESTART IDENTITY CASCADE")

# 1. Users
puts "Seeding #{NUM_USERS} users..."
default_password = BCrypt::Password.create("password123")
users = NUM_USERS.times.map do |i|
  {
    username: "user_#{i+1}_#{SecureRandom.hex(4)}",
    email: "user_#{i+1}_#{SecureRandom.hex(4)}@example.com",
    password_digest: default_password,
    created_at: Time.now,
    updated_at: Time.now
  }
end
users.each_slice(5_000) { |batch| User.insert_all!(batch) }
puts "Users done!"

# 2. Products
puts "Seeding #{NUM_PRODUCTS} products..."
products = NUM_PRODUCTS.times.map do |i|
  {
    name: "Product Model #{i+1} #{SecureRandom.hex(2).upcase}",
    description: "High quality item, perfect for all your needs. Fully backed by warranty.",
    price: rand(5.0..999.99).round(2),
    stock: rand(10..1000),
    created_at: Time.now,
    updated_at: Time.now
  }
end
products.each_slice(10_000) { |batch| Product.insert_all!(batch) }
puts "Products done!"

# 3. Orders and Order Items in Parallel Processes
# Optimize for Dual-Core i5 by spanning 4 logical processes 
NUM_PROCESSES = [Etc.nprocessors || 2, 4].min 
puts "Forking #{NUM_PROCESSES} parallel workers to seed #{NUM_ORDERS} Orders & 2.5M OrderItems..."

orders_per_process = NUM_ORDERS / NUM_PROCESSES

# Disconnect before fork to avoid shared file descriptor conflicts in PostgreSQL
ActiveRecord::Base.connection_pool.disconnect!

pids = NUM_PROCESSES.times.map do |process_idx|
  Process.fork do
    # Reconnect in child process
    ActiveRecord::Base.establish_connection
    
    start_id = process_idx * orders_per_process + 1
    end_id   = start_id + orders_per_process - 1

    is_reporter = (process_idx == 0)
    
    statuses = %w[pending processing shipped delivered]
    payment_statuses = %w[completed completed pending failed]
    
    batch_size = 5_000
    (start_id..end_id).each_slice(batch_size) do |batch_ids|
      orders_batch = []
      items_batch  = []
      payments_batch = []
      
      batch_ids.each do |order_id|
        user_id = rand(1..NUM_USERS)
        items_count = rand(1...5)
        total_amount = 0.0
        
        items_count.times do
          prod_id = rand(1..NUM_PRODUCTS)
          unit_price = rand(10.0..500.0).round(2)
          qty = rand(1..3)
          total_amount += unit_price * qty
          
          items_batch << {
            order_id: order_id,
            product_id: prod_id,
            quantity: qty,
            unit_price: unit_price,
            created_at: Time.now,
            updated_at: Time.now
          }
        end
        
        order_date = Time.now - rand(0..365).days
        status = statuses.sample
        
        orders_batch << {
          id: order_id,
          user_id: user_id,
          order_date: order_date,
          status: status,
          total_amount: total_amount.round(2),
          created_at: Time.now,
          updated_at: Time.now
        }
        
        if status != "cancelled" && rand > 0.15 # 85% chance of payment
          payments_batch << {
            order_id: order_id,
            payment_date: order_date + rand(0..5).days,
            amount: total_amount.round(2),
            status: payment_statuses.sample,
            created_at: Time.now,
            updated_at: Time.now
          }
        end
      end
      
      # Use insert_all! which bypasses model validations and inserts directly in raw batches
      Order.insert_all!(orders_batch)
      OrderItem.insert_all!(items_batch)
      Payment.insert_all!(payments_batch) if payments_batch.any?
      
      if is_reporter
        progress = ((batch_ids.last - start_id + 1).to_f / orders_per_process * 100).round(1)
        print "\r  ... Progress: #{progress}%\e[K"
      end
    end
  end
end

# Parent waits for workers
results = Process.waitall

# Re-establish parent connection
ActiveRecord::Base.establish_connection

failures = results.reject { |_, status| status.success? }
if failures.any?
  puts "\n❌ Error: #{failures.count} workers failed!"
  exit(1)
else
  puts "\n  ✓ All parallel workers finished successfully!"
end

# Update sequences so new inserts don't collide
puts "Updating primary key sequences to track with forced IDs..."
ActiveRecord::Base.connection.execute("SELECT setval('orders_id_seq', (SELECT COALESCE(MAX(id), 1) FROM orders))")
ActiveRecord::Base.connection.execute("SELECT setval('order_items_id_seq', (SELECT COALESCE(MAX(id), 1) FROM order_items))")
ActiveRecord::Base.connection.execute("SELECT setval('payments_id_seq', (SELECT COALESCE(MAX(id), 1) FROM payments))")

duration = (Time.now - start_time).round(2)
puts "\nUltra-Fast Seeding complete in #{duration} seconds!"
puts "--- Database Stats ---"
puts "  Users:       #{User.count}"
puts "  Products:    #{Product.count}"
puts "  Orders:      #{Order.count}"
puts "  Order Items: #{OrderItem.count}"
puts "  Payments:    #{Payment.count}"