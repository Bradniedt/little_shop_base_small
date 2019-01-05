class Dashboard::DiscountsController < Dashboard::BaseController
  def index
    @discounts = current_user.discounts
  end

  def new
    @discount = Discount.new
    @form_path = [:dashboard, @discount]
  end

  def create
    dp = discount_params
    @merchant = current_user
    if @merchant.discounts == []
      @discount = @merchant.discounts.create(dp)
      if @discount.save
        flash[:success] = "Discount #{@discount.id} has been created!"
        redirect_to dashboard_discounts_path
      else
        @form_path = [:dashboard, @discount]
        render :new
      end
    else
      if @merchant.discounts.first.discount_type == dp[:discount_type]
        @discount = @merchant.discounts.create(dp)
        if @discount.save
          flash[:success] = "Discount #{@discount.id} has been created!"
          redirect_to dashboard_discounts_path
        else
          @form_path = [:dashboard, @discount]
          render :new
        end
      else
        @discount = @merchant.discounts.create(dp)
        flash[:notice] = "Discount type must match existing discounts"
        @form_path = [:dashboard, @discount]
        render :new
      end
    end
  end

  private

  def discount_params
    params.require(:discount).permit(:discount_type, :amount, :quantity)
  end
end
