require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Cart workflow', type: :feature do
  before :each do
    @merchant = create(:merchant)
    @item = create(:item, user: @merchant)
  end

  describe 'shows an empty cart when no items are added' do
    scenario 'as a visitor' do
      visit cart_path
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit cart_path
    end
    after :each do
      expect(page).to have_content('Your cart is empty')
      expect(page).to_not have_button('Emtpy cart')
    end
  end

  describe 'allows visitors to add items to cart' do
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      expect(page).to have_content("You have 1 package of #{@item.name} in your cart")
      expect(page).to have_link("Cart: 1")
      expect(current_path).to eq(items_path)

      visit item_path(@item)
      click_button "Add to Cart"

      expect(page).to have_content("You have 2 packages of #{@item.name} in your cart")
      expect(page).to have_link("Cart: 2")
    end
  end

  describe 'shows an empty cart when no items are added' do
    before :each do
      @item_2 = create(:item, user: @merchant)
    end
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit item_path(@item_2)
      click_button "Add to Cart"
      visit item_path(@item_2)
      click_button "Add to Cart"

      visit cart_path

      expect(page).to_not have_content('Your cart is empty')
      expect(page).to have_button('Empty cart')

      within "#item-#{@item.id}" do
        expect(page).to have_content(@item.name)
        expect(page.find("#item-#{@item.id}-image")['src']).to have_content(@item.image)
        expect(page).to have_content("Merchant: #{@item.user.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item.price)}")
        expect(page).to have_content("Quantity: 1")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item.price*1)}")
        expect(page).to_not have_content("Discount Applied!")
      end
      within "#item-#{@item_2.id}" do
        expect(page).to have_content(@item_2.name)
        expect(page.find("#item-#{@item_2.id}-image")['src']).to have_content(@item_2.image)
        expect(page).to have_content("Merchant: #{@item_2.user.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_2.price)}")
        expect(page).to have_content("Quantity: 2")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item_2.price*2)}")
      end
      expect(page).to have_content("Total: #{number_to_currency(@item.price + (@item_2.price*2)) }")
    end
  end

  describe 'users can empty their cart if it has items in it' do
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit cart_path

      expect(page).to_not have_content('Your cart is empty')
      click_button 'Empty cart'

      expect(current_path).to eq(cart_path)
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')
    end
  end

  describe 'users can increase or decrease cart quantities' do
    before :each do
      @item_2 = create(:item, user: @merchant, inventory: 3)
    end
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit cart_path

      within "#item-#{@item.id}" do
        click_button 'Remove all from cart'
      end
      expect(page).to have_content("You have removed all packages of #{@item.name} from your cart")
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')

      visit item_path(@item_2)
      click_button "Add to Cart"
      visit cart_path

      within "#item-#{@item_2.id}" do
        click_button 'Add more to cart'
      end
      within "#item-#{@item_2.id}" do
        click_button 'Add more to cart'
      end
      expect(page).to have_link('Cart: 3')

      within "#item-#{@item_2.id}" do
        expect(page).to_not have_button('Add more to cart')
      end

      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      expect(page).to have_content("You have removed 1 package of #{@item_2.name} from your cart, new quantity is 1")
      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')
    end
  end

  describe 'users can checkout (or not) depending on role' do
    scenario 'as a visitor' do
      visit item_path(@item)
      click_button "Add to Cart"
      visit cart_path
      expect(page).to have_content('You must register or log in to check out')
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit item_path(@item)
      click_button "Add to Cart"
      visit cart_path

      click_button 'Check out'

      expect(current_path).to eq(profile_path)
      expect(page).to have_content('You have successfully checked out!')

      visit profile_orders_path
      expect(page).to have_content("Order ID #{Order.last.id}")
    end
  end

  context 'as a merchant' do
    it 'does not allow merchants to add items to a cart' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit item_path(@item)

      expect(page).to_not have_button("Add to cart")
    end
  end

  context 'as an admin' do
    it 'does not allow admins to add items to a cart' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit item_path(@item)

      expect(page).to_not have_button("Add to cart")
    end
  end
  context 'as a registered user' do
    it 'when I add an item to my cart that has a discount, and I increase the quantity to the discount quantity, I see the updated price' do
      user = create(:user)
      item_2 = create(:item, user: @merchant, price: BigDecimal.new('4.5'))
      merchant_2 = create(:merchant)
      item_3 = create(:item, user: merchant_2, price: BigDecimal.new('4.5'))
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 10, quantity: 20)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 5, quantity: 10)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit item_path(item_2)
      click_button("Add to Cart")

      visit item_path(item_3)
      click_button("Add to Cart")


      visit cart_path

      within "#item-#{item_2.id}" do
        9.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $42.75")

      within "#item-#{item_3.id}" do
        9.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $40.00")

      within "#item-#{item_2.id}" do
        expect(page).to have_content("Discount Applied!")
      end

      within "#item-#{item_3.id}" do
        expect(page).to have_content("Discount Applied!")
      end
    end
    it 'when I add an item to my cart that has a discount, and I increase the quantity over the discount quantity, I see the updated price' do
      user = create(:user)
      item_2 = create(:item, user: @merchant, price: BigDecimal.new('4'))
      merchant_2 = create(:merchant)
      item_3 = create(:item, user: merchant_2, price: BigDecimal.new('4'))
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 10, quantity: 20)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 5, quantity: 10)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit item_path(item_2)
      click_button("Add to Cart")

      visit item_path(item_3)
      click_button("Add to Cart")


      visit cart_path

      within "#item-#{item_2.id}" do
        12.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $49.40")

      within "#item-#{item_3.id}" do
        12.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $47.00")
    end
    it 'when I add an item to my cart that has a discount, and I increase the quantity up to the highest discount quantity, I see the updated price' do
      user = create(:user)
      item_2 = create(:item, user: @merchant, price: BigDecimal.new('4'))
      merchant_2 = create(:merchant)
      item_3 = create(:item, user: merchant_2, price: BigDecimal.new('4'))
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 10, quantity: 20)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 5, quantity: 10)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit item_path(item_2)
      click_button("Add to Cart")

      visit item_path(item_3)
      click_button("Add to Cart")


      visit cart_path

      within "#item-#{item_2.id}" do
        19.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $76.00")

      within "#item-#{item_3.id}" do
        19.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $75.00")
    end
    it 'when I add an item to my cart that has a discount, and I increase the quantity over the highest discount quantity, I see the updated price' do
      user = create(:user)
      item_2 = create(:item, user: @merchant, price: BigDecimal.new('4'))
      merchant_2 = create(:merchant)
      item_3 = create(:item, user: merchant_2, price: BigDecimal.new('4'))
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_1 = @merchant.discounts.create(discount_type: 0, amount: 10, quantity: 20)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 5, quantity: 10)
      discount_2 = merchant_2.discounts.create(discount_type: 1, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit item_path(item_2)
      click_button("Add to Cart")

      visit item_path(item_3)
      click_button("Add to Cart")


      visit cart_path

      within "#item-#{item_2.id}" do
        22.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $87.40")

      within "#item-#{item_3.id}" do
        22.times do
          click_button 'Add more to cart'
        end
      end
      expect(page).to have_content("Subtotal: $87.00")
    end
  end
end
