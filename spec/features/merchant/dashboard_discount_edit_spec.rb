require 'rails_helper'

describe 'as a merchant user' do
  context 'when I visit my discounts' do
    it 'should allow me to edit a discount' do
      merch = create(:merchant)
      discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = merch.discounts.create(discount_type: 0, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_discounts_path

      within("#discount-#{discount_1.id}") do
        expect(page).to have_link('Edit This Discount')
        click_on('Edit This Discount')
      end

      expect(current_path).to eq(edit_dashboard_discount_path(discount_1))

      fill_in 'discount[amount]', with: 15
      fill_in 'discount[quantity]', with: 20
      click_on("Update Discount")

      expect(current_path).to eq(dashboard_discounts_path)

      discount = Discount.find(discount_1.id)

      expect(page).to have_content("Discount #{discount_1.id} has been updated!")
      within("#discount-#{discount.id}") do
        expect(page).to have_content(discount.id)
        expect(page).to have_content(discount.discount_type)
        expect(page).to have_content(discount.amount)
        expect(page).to have_content(discount.quantity)
        expect(page).to have_link('Edit This Discount')
        expect(page).to have_link('Delete This Discount')
      end
    end
    it 'should not allow me to edit a discount if I edit the type to one that does not match my other discount types' do
      merch = create(:merchant)
      discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = merch.discounts.create(discount_type: 0, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_discounts_path

      within("#discount-#{discount_1.id}") do
        expect(page).to have_link('Edit This Discount')
        click_on('Edit This Discount')
      end

      expect(current_path).to eq(edit_dashboard_discount_path(discount_1))

      fill_in 'discount[discount_type]', with: 1
      fill_in 'discount[amount]', with: 15
      fill_in 'discount[quantity]', with: 20
      click_on("Update Discount")

      expect(page).to have_content("Discount type must be the same as your other discounts!")
    end
    it 'should not allow me to edit a discount if I enter in bad information' do
      merch = create(:merchant)
      discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = merch.discounts.create(discount_type: 0, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_discounts_path

      within("#discount-#{discount_1.id}") do
        expect(page).to have_link('Edit This Discount')
        click_on('Edit This Discount')
      end

      expect(current_path).to eq(edit_dashboard_discount_path(discount_1))

      fill_in 'discount[amount]', with: "j"
      fill_in 'discount[quantity]', with: "j"
      click_on("Update Discount")

      expect(page).to have_content('Amount is not a number')
      expect(page).to have_content('Quantity is not a number')
    end
  end
end
