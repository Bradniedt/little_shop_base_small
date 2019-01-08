require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
  end

  describe 'class methods' do
  end

  describe 'instance methods' do
    it '.discount_number' do
      merch = create(:merchant)
      merch_2 = create(:merchant)
      discount = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = merch_2.discounts.create(discount_type: 1, amount: 5, quantity: 10)
      item = create(:item, user: merch)
      item_2 = create(:item, user: merch_2)
      oi = create(:order_item, item: item, quantity: 10, price: 3)
      oi_2 = create(:order_item, item: item_2, quantity: 10, price: 3)

      expect(oi.discount_number).to eq("5%")
      expect(oi_2.discount_number).to eq("$5")
    end
    it '.subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end
    it '.discount_check' do
      merch = create(:merchant)
      discount = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      item = create(:item, user: merch)
      oi = create(:order_item, item: item, quantity: 10, price: 3)
      oi_2 = create(:order_item, quantity: 5, price: 3)

      expect(oi.discount_check).to eq(true)
      expect(oi_2.discount_check).to eq(false)
    end
  end
end
