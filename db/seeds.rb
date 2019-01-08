require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

OrderItem.destroy_all
Order.destroy_all
Item.destroy_all
User.destroy_all
Discount.destroy_all

admin = create(:admin)
user = create(:user)
merchant_1 = create(:merchant, email: "email_1@aol.com", password: "11111")

merchant_2, merchant_3, merchant_4 = create_list(:merchant, 3)

discount_1 = merchant_1.discounts.create(discount_type: 0, amount: 5, quantity: 10)
discount_2 = merchant_1.discounts.create(discount_type: 0, amount: 10, quantity: 20)
discount_3 = merchant_2.discounts.create(discount_type: 0, amount: 5, quantity: 10)
discount_4 = merchant_2.discounts.create(discount_type: 0, amount: 10, quantity: 20)
discount_5 = merchant_3.discounts.create(discount_type: 1, amount: 5, quantity: 10)
discount_6 = merchant_3.discounts.create(discount_type: 1, amount: 10, quantity: 25)
discount_7 = merchant_4.discounts.create(discount_type: 1, amount: 5, quantity: 10)
discount_8 = merchant_4.discounts.create(discount_type: 1, amount: 10, quantity: 30)

inactive_merchant_1 = create(:inactive_merchant)
inactive_user_1 = create(:inactive_user)

item_1 = create(:item, user: merchant_1, inventory: 31)
item_2 = create(:item, user: merchant_2, inventory: 45)
item_3 = create(:item, user: merchant_3, inventory: 11)
item_4 = create(:item, user: merchant_4, inventory: 52)
create_list(:item, 10, user: merchant_1)

inactive_item_1 = create(:inactive_item, user: merchant_1)
inactive_item_2 = create(:inactive_item, user: inactive_merchant_1)

Random.new_seed
rng = Random.new

order = create(:completed_order, user: user)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 11, created_at: rng.rand(3).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 7, created_at: rng.rand(23).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 26, created_at: rng.rand(5).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 13, created_at: rng.rand(23).hour.ago, updated_at: rng.rand(59).minutes.ago)

order = create(:order, user: user)
create(:order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: rng.rand(23).days.ago, updated_at: rng.rand(23).hours.ago)

order = create(:cancelled_order, user: user)
create(:order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: rng.rand(23).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: rng.rand(23).hour.ago, updated_at: rng.rand(59).minutes.ago)

order = create(:completed_order, user: user)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: rng.rand(4).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: rng.rand(23).hour.ago, updated_at: rng.rand(59).minutes.ago)
