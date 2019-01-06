require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:discount_type) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).only_integer }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
  end
  describe 'relationships' do
    it { should belong_to(:user) }
  end
  describe 'class methods' do
    context "#type_check" do
      it 'should return true if the discount type is the same as others for that merchant, and false if not.' do
        merch = create(:merchant)
        discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
        discount_2 = merch.discounts.create(discount_type: 0, amount: 10, quantity: 20)

        expect(Discount.type_check(0, merch.id)).to eq(true)
        expect(Discount.type_check(1, merch.id)).to eq(false)
      end
    end
  end
end
