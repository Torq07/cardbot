require 'active_record'
require './models/cardtransaction'

class Card < ActiveRecord::Base
	has_many :card_transactions
	belongs_to :customer
	belongs_to :card_product
end
