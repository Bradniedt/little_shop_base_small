require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :description }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).only_integer }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of :slug }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :order_items }
    it { should have_many(:orders).through(:order_items) }
  end

  describe 'class methods' do
    describe 'item popularity' do
      before :each do
        merchant = create(:merchant)
        @items = create_list(:item, 6, user: merchant)
        user = create(:user)

        order = create(:completed_order, user: user)
        create(:fulfilled_order_item, order: order, item: @items[3], quantity: 7)
        create(:fulfilled_order_item, order: order, item: @items[1], quantity: 6)
        create(:fulfilled_order_item, order: order, item: @items[0], quantity: 5)
        create(:fulfilled_order_item, order: order, item: @items[2], quantity: 3)
        create(:fulfilled_order_item, order: order, item: @items[5], quantity: 2)
        create(:fulfilled_order_item, order: order, item: @items[4], quantity: 1)
      end
      it '.item_popularity' do
        expect(Item.item_popularity(4, :desc)).to eq([@items[3], @items[1], @items[0], @items[2]])
        expect(Item.item_popularity(4, :asc)).to eq([@items[4], @items[5], @items[2], @items[0]])
      end
      it '.popular_items' do
        expect(Item.popular_items(3)).to eq([@items[3], @items[1], @items[0]])
      end
      it '.unpopular_items' do
        expect(Item.unpopular_items(3)).to eq([@items[4], @items[5], @items[2]])
      end
    end
  end

  describe 'instance methods' do
    it '.discount_number' do
      merch = create(:merchant)
      merch_2 = create(:merchant)
      discount = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = merch_2.discounts.create(discount_type: 1, amount: 5, quantity: 10)
      item = create(:item, user: merch)
      item_2 = create(:item, user: merch_2)

      expect(item.discount_number(10)).to eq("5%")
      expect(item_2.discount_number(10)).to eq("$5")
    end
    it '.discount_check' do
      user = create(:merchant)
      user_2 = create(:merchant)
      discount = user.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = user.discounts.create(discount_type: 0, amount: 10, quantity: 20)
      item = create(:item, name: 'cheese grater',  user: user)
      item_2 = create(:item, name: 'cheese grater',  user: user_2)

      expect(item.discount_check(9)).to eq(false)
      expect(item.discount_check(10)).to eq(true)
      expect(item.discount_check(15)).to eq(true)
      expect(item.discount_check(20)).to eq(true)
      expect(item.discount_check(22)).to eq(true)

      expect(item_2.discount_check(1)).to eq(false)
      expect(item_2.discount_check(10)).to eq(false)
    end
    it '.make_slug' do
      user = create(:merchant)
      item = create(:item, name: 'cheese grater',  user: user)

      expect(item.slug).to eq("cheesegrater-0")
    end

    it '.check_slug' do
      user = create(:merchant)
      item_1 = create(:item, name: 'cheese grater',  user: user)
      item_2 = create(:item, name: 'cheese grater',  user: user)
      item_3 = create(:item, name: 'cheese grater',  user: user)
      #this method will be called from within the make_slug method
      expect(item_2.slug).to eq('cheesegrater-1')
    end
    it '.avg_fulfillment_time' do
      item = create(:item)
      merchant = item.user
      user = create(:user)
      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item, created_at: 4.days.ago, updated_at: 1.days.ago)
      create(:fulfilled_order_item, order: order, item: item, created_at: 1.hour.ago, updated_at: 30.minutes.ago)

      expect(item.avg_fulfillment_time).to include("1 day 12:15:00")
    end

    it '.ever_ordered?' do
      item_1 = create(:item)
      item_2 = create(:item)
      order = create(:completed_order)
      create(:fulfilled_order_item, order: order, item: item_1, created_at: 4.days.ago, updated_at: 1.days.ago)

      expect(item_1.ever_ordered?).to eq(true)
      expect(item_2.ever_ordered?).to eq(false)
    end
  end
end
