require 'rails_helper'

describe 'as a merchant user' do
  context 'when I visit my dashboard' do
    it 'should have a link to see my discounts' do
      merch = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch)
      visit dashboard_path

      expect(page).to have_link('My Discounts')
      click_on('My Discounts')
      expect(current_path).to eq(dashboard_discounts_path)
    end
  end
end
