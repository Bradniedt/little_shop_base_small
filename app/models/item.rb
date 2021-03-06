class Item < ApplicationRecord

  belongs_to :user, foreign_key: 'merchant_id'
  has_many :order_items
  has_many :orders, through: :order_items

  validates_presence_of :name, :description
  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :inventory, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :slug, uniqueness: true

  before_create :make_slug

  def self.item_popularity(count, order)
    Item.joins(:order_items)
      .select("items.*, sum(order_items.quantity) as total_ordered")
      .order("total_ordered #{order}")
      .group(:id)
      .limit(count)
  end

  def self.popular_items(count)
    item_popularity(count, :desc)
  end

  def self.unpopular_items(count)
    item_popularity(count, :asc)
  end

  def avg_fulfillment_time
    results = ActiveRecord::Base.connection.execute("select avg(updated_at - created_at) as avg_f_time from order_items where item_id=#{self.id} and fulfilled='t'")
    if results.present?
      return results.first['avg_f_time']
    else
      return nil
    end
  end

  def ever_ordered?
    OrderItem.find_by_item_id(self.id) !=  nil
  end

  def to_param
    self.slug
  end

  def discount_check(qty)
    merchant = User.find(self.merchant_id)
    if merchant.discounts == []
      return false
    else
      return merchant.discounts.qty_check(qty)
    end
  end

  def discount_number(qty)
    merchant = User.find(self.merchant_id)
    discount = merchant.discounts.qty_match(qty)
    num = discount.amount
    if discount.discount_type == 0
      return "#{num}%"
    else
      return "$#{num}"
    end
  end

  private

  def make_slug
    if self.name
      self.slug =   "#{self.name.delete(' ').downcase}-0"
      check_slug(self.slug)
    end
  end

  def check_slug(slug)
    n = slug.chars.last.to_i if slug
    if Item.find_by(slug: self.slug)
      n += 1
      self.slug =   "#{self.name.delete(' ').downcase}-#{n}"
      check_slug(self.slug)
    else
      self.slug
    end
  end

end
