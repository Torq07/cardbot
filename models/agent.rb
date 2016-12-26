require 'active_record'
require './models/cardtransaction'

class Agent < ActiveRecord::Base
	has_many :card_transactions
end
