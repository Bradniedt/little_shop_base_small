require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:discount_type) }
    it { should validate_presence_of(:amount).only_integer }
  end
  decribe 'relationships' do
    it { should belong_to(:user)}
  end
end
