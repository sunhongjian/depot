class CombineItemsInCart < ActiveRecord::Migration[5.1]
  def up
    # 把购物车中同一个产品的多个商品替换为单个商品
    Cart.all.each do |cart|
      # 计算购物车中每个产品的数量
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums.each do |product_id, quantity|
        if quantity > 1
          # 删除同一个产品的多个商品
          cart.line_items.where(product_id: product_id).delete_all

          # 替换为单个商品
          item = cart.line_items.build(product_id: product_id)
          item.quantity = quantity
          item.save!
       end
      end
    end
  end

  def down
    # 把数量大于1的商品分割为多个商品
    LineItem.where("quantity>1").each do |line_item|
      # 添加包含单个相同产品的商品
      line_item.quantity.times do
        LineItem.create(
                    cart_id: line_item.cart_id,
                    product_id: line_item.product_id,
                    quantity: 1
        )
      end
      line_item.destroy
    end
  end
end
