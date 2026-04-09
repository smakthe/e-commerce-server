class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.datetime :payment_date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :status, null: false
      t.timestamps
    end
  end
end
