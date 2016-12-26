require 'active_record'
require './models/cardtransaction'

class Card < ActiveRecord::Base
	has_many :card_transactions
	belongs_to :customer
	has_one :card_product
end
