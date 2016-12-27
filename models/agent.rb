require 'active_record'
require './models/cardtransaction'

class Agent < ActiveRecord::Base
	has_many :card_transactions
	has_many :cards, through: :card_transactions
end
