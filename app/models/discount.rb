class Discount < ApplicationRecord
  validates :discount_type, presence: true, allow_blank: false
  validates :amount, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    allow_blank: false}
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    allow_blank: false }

  belongs_to :user

  def self.type_check(type, merchant_id)
    existing_type = self.where(user_id: merchant_id).pluck(:discount_type).uniq.first
    if existing_type == type
      return true
    else
      return false
    end
  end

  def self.qty_match(num)
    discount = self.where("discounts.quantity <= ?", num)
    discount.first
  end

  def self.qty_check(num)
    discount = self.where("discounts.quantity <= ?", num)
    if discount == []
      return false
    else
      return true
    end
  end
end
