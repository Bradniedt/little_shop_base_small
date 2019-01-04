class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.integer :discount_type
      t.integer :amount
      t.integer :quantity
    end
  end
end
