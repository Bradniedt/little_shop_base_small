class Cart
  attr_reader :contents

  def initialize(initial_contents)
    @contents = initial_contents || Hash.new(0)
  end

  def total_count
    @contents.values.sum
  end

  def count_of(item_id)
    @contents[item_id.to_s].to_i
  end

  def add_item(item_id)
    @contents[item_id.to_s] ||= 0
    @contents[item_id.to_s] += 1
  end

  def subtract_item(item_id)
    @contents[item_id.to_s] -= 1
    @contents.delete(item_id.to_s) if @contents[item_id.to_s] == 0
  end

  def remove_all_of_item(item_id)
    @contents.delete(item_id.to_s)
  end

  def items
    @contents.keys.map do |item_id|
      Item.includes(:user).find(item_id)
    end
  end

  def subtotal(item_id)
    item = Item.find(item_id)
    merchant = User.find(item.merchant_id)
    count = count_of(item_id)
    if merchant.discounts == []
      item.price * count
    else
      if merchant.discounts.type_check(0, merchant.id) && merchant.discounts.qty_check(count)
        discount = merchant.discounts.qty_match(count)
        total = (item.price * count)
        total - (total * (discount.amount / 100.0))
      elsif merchant.discounts.type_check(1, merchant.id) && merchant.discounts.qty_check(count)
        discount = merchant.discounts.qty_match(count)
        (item.price * count) - discount.amount
      else
        item.price * count
      end
    end
    #ADD CODE TO SUBTRACT THE DISCOUNT AMOUNT IF A DISCOUNT IS PRESENT.
    #THIS SHOULD BE AN ITEM INSTANCE METHOD - IF_DISCOUNT SHOULD SEE IF THE ITEM'S MERCHANT
    #HAS A BULK DISCOUNT.
  end

  def grand_total
    @contents.keys.map do |item_id|
      subtotal(item_id)
    end.sum
  end
end
