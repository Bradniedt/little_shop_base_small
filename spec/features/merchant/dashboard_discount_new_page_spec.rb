require 'rails_helper'

describe 'as a merchant user' do
  context 'when I visit my dashboard discounts index page and I click on create a new discount' do
    it 'takes me to a form to create a new discount, and I can create a new discount' do
      merch = create(:merchant)
      discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_discounts_path

      click_on('Create A New Discount')
      expect(current_path).to eq(new_dashboard_discount_path)

      fill_in 'discount[discount_type]', with: 0
      fill_in 'discount[amount]', with: 5
      fill_in 'discount[quantity]', with: 10
      click_on("Create Discount")

      discount = Discount.all.last

      expect(current_path).to eq(dashboard_discounts_path)
      expect(page).to have_content("Discount #{discount.id} has been created!")
      within("#discount-#{discount.id}") do
        expect(page).to have_content(discount.id)
        expect(page).to have_content(discount.discount_type)
        expect(page).to have_content(discount.amount)
        expect(page).to have_content(discount.quantity)
        expect(page).to have_link('Edit This Discount')
        expect(page).to have_link('Delete This Discount')
      end
    end
    it 'takes me to a form to create a new discount, and I can create a new discount' do
      merch = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_discounts_path

      click_on('Create A New Discount')
      expect(current_path).to eq(new_dashboard_discount_path)

      fill_in 'discount[discount_type]', with: 0
      fill_in 'discount[amount]', with: 5
      fill_in 'discount[quantity]', with: 10
      click_on("Create Discount")

      discount = Discount.all.last

      expect(current_path).to eq(dashboard_discounts_path)
      expect(page).to have_content("Discount #{discount.id} has been created!")
      within("#discount-#{discount.id}") do
        expect(page).to have_content(discount.id)
        expect(page).to have_content(discount.discount_type)
        expect(page).to have_content(discount.amount)
        expect(page).to have_content(discount.quantity)
        expect(page).to have_link('Edit This Discount')
        expect(page).to have_link('Delete This Discount')
      end
    end
    it 'takes me to a form to create a new discount, and it wont let me create a discount without all fields filled' do
      merch = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_discounts_path

      click_on('Create A New Discount')
      expect(current_path).to eq(new_dashboard_discount_path)

      click_on("Create Discount")

      expect(page).to have_content("Discount type can't be blank")
      expect(page).to have_content("Amount can't be blank")
      expect(page).to have_content("Amount is not a number")
      expect(page).to have_content("Quantity can't be blank")
      expect(page).to have_content("Quantity is not a number")
    end
    it 'takes me to a form to create a new discount, and I can only create a discount with the same type as my other discounts' do
      merch = create(:merchant)
      discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_discounts_path

      click_on('Create A New Discount')
      expect(current_path).to eq(new_dashboard_discount_path)

      fill_in 'discount[discount_type]', with: 1
      fill_in 'discount[amount]', with: 10
      fill_in 'discount[quantity]', with: 20
      click_on("Create Discount")

      expect(page).to have_content("Discount type must match existing discounts")
    end
  end
end
