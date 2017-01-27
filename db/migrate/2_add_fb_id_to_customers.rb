class AddFbIdToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :fb_id, :integer, limit: 8 
  end

  def self.down
    remove_column :comments, :post_id
  end
end
