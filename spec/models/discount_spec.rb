require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:discount_type) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).only_integer }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end
  describe 'relationships' do
    it { should belong_to(:user) }
  end
end
