class CreateAgentsEtc < ActiveRecord::Migration
  def change
    create_table :agents, force: true do |t|
      t.integer :aid
      t.string :first_name
      t.string :last_name
    end

    create_table :stores, force: true do |t|
      t.string :store_name
    end

    create_table :customers, force: true do |t|
      t.string :first_name
      t.string :last_name
    end	

    create_table :card_products, force: true do |t|
      t.string :type_name
      t.references :store, index: true, foreign_key: true
    end

    create_table :cards, force: true do |t|
      t.string :status
      t.float :balance, default: 0
      t.date :expiring_date
      t.references :card_product, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.references :store, index: true, foreign_key: true
    end

    create_table :card_transactions, force: true do |t|
      t.string :status
      t.string :trans_type
      t.float :amount
      t.references :store, index: true, foreign_key: true
      t.references :agent, index: true, foreign_key: true
      t.references :card, index: true, foreign_key: true
    end

  end
end
