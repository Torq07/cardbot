require 'active_record'

class CardProduct < ActiveRecord::Base
	belongs_to :store
	has_many :cards
end
