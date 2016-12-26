require 'active_record'

class CardTransaction < ActiveRecord::Base
	belongs_to :agent
	belongs_to :store
	belongs_to :card
end
