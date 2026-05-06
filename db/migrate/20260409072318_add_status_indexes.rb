class AddStatusIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :orders, :status
    add_index :payments, :status
  end
end
