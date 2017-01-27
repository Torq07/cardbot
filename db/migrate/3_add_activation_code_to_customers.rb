class AddActivationCodeToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :activation_code, :integer, limit: 8
  end

  def self.down
    remove_column :customers, :activation_code
  end
end
