class Discount < ApplicationRecord
  validates_presence_of :discount_type
  validates :amount, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0 }

  belongs_to :user
end
