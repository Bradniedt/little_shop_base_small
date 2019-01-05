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
end
