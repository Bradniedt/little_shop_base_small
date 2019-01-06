class Dashboard::DiscountsController < Dashboard::BaseController
  def index
    @discounts = Discount.where(user_id: current_user.id)
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

  def edit
    @discount = Discount.find(params[:id])
    @form_path = [:dashboard, @discount]
  end

  def update
    @discount = Discount.find(params[:id])
    dp = discount_params
    @merchant = current_user
    if @merchant.discounts.length == 1
      @discount.update(dp)
      if @discount.save
        flash[:success] = "Discount #{@discount.id} has been updated!"
        redirect_to dashboard_discounts_path
      else
        @form_path = [:dashboard, @discount]
        render :edit
      end
    else
      if Discount.type_check(dp[:discount_type].to_i, @merchant.id)
        @discount.update(dp)
        if @discount.save
          flash[:success] = "Discount #{@discount.id} has been updated!"
          redirect_to dashboard_discounts_path
        else
          @form_path = [:dashboard, @discount]
          render :edit
        end
      else
        flash[:notice] = "Discount type must be the same as your other discounts!"
        @form_path = [:dashboard, @discount]
        render :edit
      end
    end
  end

  def destroy
    merchant = current_user
    discount = merchant.discounts.find(params[:id])
    id = discount.id
    Discount.find(id).delete
    flash[:success] = "Discount id ##{id} was deleted."
    redirect_to dashboard_discounts_path
  end

  private

  def discount_params
    params.require(:discount).permit(:discount_type, :amount, :quantity)
  end
end
