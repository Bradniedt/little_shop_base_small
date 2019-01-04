class AddDiscountToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :discount, foreign_key: true
  end
end
