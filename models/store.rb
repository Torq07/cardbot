require 'active_record'

class Store < ActiveRecord::Base
	has_many :card_products
	has_many :card_transactions
end
