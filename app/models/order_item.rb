class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def subtotal
    quantity * price
  end

  def discount_check
    item = Item.find(self.item_id)
    merchant = User.find(item.merchant_id)
    if merchant.discounts == []
      return false
    else
      if merchant.discounts.qty_check(self.quantity)
        return true
      else
        return false
      end
    end
  end

  def discount_number
    item = Item.find(self.item_id)
    merchant = User.find(item.merchant_id)
    discount = merchant.discounts.qty_match(self.quantity)
    num = discount.amount
    if discount.discount_type == 0
      return "#{num}%"
    else
      return "$#{num}"
    end
  end
end
