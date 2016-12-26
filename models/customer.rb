require 'active_record'

class Customer < ActiveRecord::Base
		has_many :cards
end
