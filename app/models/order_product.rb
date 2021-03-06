# == Schema Information
#
# Table name: order_products
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  product_id :integer
#  count      :integer          default(1)
#

class OrderProduct < ActiveRecord::Base
  after_create :remove_from_stock
  before_destroy :put_back_in_stock

  belongs_to :order
  belongs_to :product

  validates :product, presence: true
  validates :count, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :product

  def product_attributes=(attributes)
    self.product = Product.find(attributes[:id])
    super
  end

  private

    def remove_from_stock
      product.stock -= self.count
      product.save
    end

    def put_back_in_stock
      product.stock += self.count
      product.save
    end
end
