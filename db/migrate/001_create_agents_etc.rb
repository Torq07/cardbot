class CreateAgentsEtc < ActiveRecord::Migration
  def change
    create_table :agents, force: true do |t|
      t.integer :aid
      t.string :first_name
      t.string :last_name
    end

    create_table :stores do |t|
      t.string :store_name
    end

    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
    end	

    create_table :card_products, force: true do |t|
      t.string :type_name
      t.integer :store_id, limit: 8
    end

    change_table :customers do |t|
      t.change :id, :int8
    end

    change_table :stores do |t|
      t.change :id, :int8
    end

    create_table :cards, force: true do |t|
      t.string :status
      t.float :balance, default: 0
      t.date :expiring_date
      t.references :card_product, index: true, foreign_key: true
      t.integer :customer_id, limit: 8
      t.integer :store_id, limit: 8
    end


    create_table :card_transactions, force: true do |t|
      t.string :status
      t.string :trans_type
      t.float :amount
      t.integer :store_id, limit: 8
      t.references :agent, index: true, foreign_key: true
      t.references :card, index: true, foreign_key: true
      t.timestamps
    end

    add_foreign_key :cards, :customers
    add_foreign_key :cards, :stores
    add_foreign_key :card_transactions, :stores
    add_foreign_key :card_products, :stores

  end
end
