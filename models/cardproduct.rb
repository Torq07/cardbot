require 'active_record'

class CardProduct < ActiveRecord::Base
	belongs_to :store
	belongs_to :card
end
