require 'rails_helper'

describe 'as a merchant user' do
  context 'when I visit my dashboard' do
    it 'should have a link to see my discounts' do
      merch = create(:merchant)
      discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = merch.discounts.create(discount_type: 0, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_path

      expect(page).to have_link('My Discounts')
      click_on('My Discounts')
      expect(current_path).to eq(dashboard_discounts_path)

      expect(page).to have_link('Create A New Discount')

      within("#discount-#{discount_1.id}") do
        expect(page).to have_content(discount_1.id)
        expect(page).to have_content(discount_1.discount_type)
        expect(page).to have_content(discount_1.amount)
        expect(page).to have_content(discount_1.quantity)
        expect(page).to have_link('Edit This Discount')
        expect(page).to have_link('Delete This Discount')
      end
      within("#discount-#{discount_2.id}") do
        expect(page).to have_content(discount_2.id)
        expect(page).to have_content(discount_2.discount_type)
        expect(page).to have_content(discount_2.amount)
        expect(page).to have_content(discount_2.quantity)
        expect(page).to have_link('Edit This Discount')
        expect(page).to have_link('Delete This Discount')
      end
    end
    it 'should be able to delete a discount' do
      merch = create(:merchant)
      discount_1 = merch.discounts.create(discount_type: 0, amount: 5, quantity: 10)
      discount_2 = merch.discounts.create(discount_type: 0, amount: 10, quantity: 20)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_path

      expect(page).to have_link('My Discounts')
      click_on('My Discounts')
      expect(current_path).to eq(dashboard_discounts_path)

      within("#discount-#{discount_1.id}") do
        expect(page).to have_content(discount_1.id)
        expect(page).to have_content(discount_1.discount_type)
        expect(page).to have_content(discount_1.amount)
        expect(page).to have_content(discount_1.quantity)
        expect(page).to have_link('Edit This Discount')
        expect(page).to have_link('Delete This Discount')
        click_on("Delete This Discount")
      end
      merchant = User.find(merch.id)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      expect(current_path).to eq(dashboard_discounts_path)

      expect(page).to_not have_css("#discount-#{discount_1.id}")
      expect(page).to have_content("Discount id ##{discount_1.id} was deleted.")
    end
  end
end
