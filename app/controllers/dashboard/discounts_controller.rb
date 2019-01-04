class Dashboard::DiscountsController < Dashboard::BaseController
  def index
    @discounts = current_user.discounts
  end
end
