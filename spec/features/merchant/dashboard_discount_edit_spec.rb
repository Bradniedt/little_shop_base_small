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

      fill_in 'discount[discount_type]', with: 0
      fill_in 'discount[amount]', with: 15
      fill_in 'discount[quantity]', with: 20
      click_on("Edit Discount")
    end
  end
end
