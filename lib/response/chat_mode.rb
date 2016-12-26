Dir['./models/*'].each {|file| require file unless File.directory?(file)} 
Dir['./lib/*'].each {|file| require file unless File.directory?(file) }
require 'date'

class ChatMode

	attr_reader :message
  attr_reader :bot
  attr_reader :user

  include MainRequests

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = options[:user]
    @answers = ['Redeem Value','Check Balance','Activate Card','Deactivate Card' ]
  end

  def response
  	if message.reply_to_message
  		case message.reply_to_message.text
  		when 'Please enter card id for redeem card'
  			card_id = message.text.strip.to_i
  			if Card.exists?(card_id)
  				user.card_transactions.create(card_id: card_id, trans_type: 'redeem')
  				request_redeem_value
  			else
  				request(text:"Sorry there is no card with such id",answers:@answers)
  			end	
  		when 'Please enter redeem value'	
  			user.card_transactions.last.update_attribute(:amount, message.text.strip.to_i)
  			run_trunsactions
  		when 'Please enter card id for card activation'
  			card_id = message.text.strip.to_i
  			if Card.exists?(card_id)
  				user.card_transactions.create(card_id: card_id, trans_type:'activation')
  			else
  				Card.create(id:card_id)
  				user.card_transactions.create(card_id: card_id, trans_type:'activation')
  			end	
  			request_customer_id
  		when 'Please enter customer id'
  			customer_id = message.text.strip.to_i
  			if Customer.exists?(customer_id)
  				user.card_transactions.last.card.update_attribute(:customer_id,customer_id)	
  			else
  				request(text:"Sorry there is no customer with such id",answers:@answers)
  				user.card_transactions.last.destroy
  			end	
  			run_trunsactions
  		when 'Please enter card id for card deactivation'
  			card_id = message.text.strip.to_i
  			if Card.exists?(card_id)
  				user.card_transactions.create(card_id: card_id, trans_type: 'deactivation')
  			else
  				request(text:"Sorry there is no card with such id",answers:@answers)
  			end	
  			run_trunsactions
  		when 'Please enter card id'
  			card_id = message.text.strip.to_i
  			if Card.exists?(card_id)
  				balance = Card.find(card_id).balance
  				request(text:"Card balance is :#{balance}",answers:@answers)
  			else
  				request(text:"Sorry there is no card with such id",answers:@answers)
  			end	
  		end
	  elsif message.text
	    case message.text
	      when '/start'
	        answer_with_greeting_message
	      when 'Redeem Value'
	      	redeem_value
				when 'Check Balance'
					check_balance
				when 'Activate Card'
					activate_card
				when 'Deactivate Card'
					deactivate_card 
	    end
	  elsif message.location
	  	
	  elsif message.document
	    FileUploader.new(bot:bot).load(message.document.file_id,message.document.file_name)
	  end
	end
	  
	def answer_with_greeting_message
	  text = I18n.t('greeting_message')
	  request(text:text, answers:@answers)
	end

	def answer_with_farewell_message
	  text = I18n.t('farewell_message')
	  request(text:text, answers:@answers)
	end

	def redeem_value
		text = 'Please enter card id for redeem card'
		request(text: text, force_reply: true)	 
	end

	def request_redeem_value
		text = 'Please enter redeem value'
		request(text: text, force_reply: true)	 
	end

	def check_balance
		text="Please enter card id"
		request(text: text, force_reply: true)	 
	end

	def run_trunsactions
		CardTransaction.where(status: nil).each do |t| 
			case t.trans_type
			when 'redeem' 
				t.card.balance-=t.amount
				t.card.status = 'expired' if t.card.balance<0
				t.card.save
				t.update_attribute(:status, 'done')
				request(text:'Card was redeem',answers:@answers)
			when 'deactivation' 
				t.card.update_attribute(:status, 'deactivated')
				t.update_attribute(:status, 'done')
				request(text:'Card was deactivated',answers:@answers)
			when 'activation' 
				t.card.update_attribute(:status, 'activated')
				t.update_attribute(:status, 'done')
				request(text:'Card was activated',answers:@answers)
			end 
		end	
	end

	def activate_card
		text = 'Please enter card id for card activation'
		request(text: text, force_reply: true)	
	end

	def deactivate_card
		text = 'Please enter card id for card deactivation'
		request(text: text, force_reply: true)	
	end

	def request_customer_id
		text = 'Please enter customer id'
		request(text: text, force_reply: true)	
	end

end	