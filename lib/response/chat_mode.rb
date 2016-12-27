Dir['./models/*'].each {|file| require file unless File.directory?(file)} 
Dir['./lib/*'].each {|file| require file unless File.directory?(file) }
require 'date'
require 'prawn'

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
  				if Card.find(card_id).card_product.type_name == 'flyer'
  					run_trunsactions
  				else	
  					request_redeem_value 
  				end	
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
  			# else
  			# 	Card.create(id:card_id)
  			# 	user.card_transactions.create(card_id: card_id, trans_type:'activation')
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
				when /\/print/i
					print_stats
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
				t.card.balance-=t.amount if t.amount
				t.card.status = 'expired' if t.card.balance<0
				t.card.save
				t.update_attribute(:status, 'done')
				redeem_succesful(t.card)
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

	def redeem_succesful(card)
		cid = card.customer_id
		balance = card.balance
		card_id = card.id
		text="Redemption Successful\nCust id: #{cid}\nCard No: #{card_id}\nNew Balance $#{balance}"
		pdf=generate_pdf(cid,balance,card.id)
		request(text:text,answers:@answers)
		MessageSender.new(bot:bot, chat: message.from, document:pdf).send_document
	end

	def generate_pdf(cid,balance,card_id)
		time_now=Time.now.strftime("%Y_%m_%d_%H_%M")
		pdf_name="Card_#{card_id}_#{time_now}.pdf"
		Prawn::Document.generate("/home/torq07/Work/Fiverr/piousmusabaila/cardbot/recipies/#{pdf_name}") do
			text "Redemption receipt", :align => :center, :size => 18
			text "Date: #{Time.now.strftime("%Y/%m/%d %H:%M")}", :align => :center, :size => 16
			move_down 20
		  text "Cust id: #{cid}"
			stroke_horizontal_rule
			move_down 10
		  text "Card No: #{card_id}"
			stroke_horizontal_rule
			move_down 10
		  text "New Balance: #{balance}"
			stroke_horizontal_rule
			move_down 50
			image "/home/torq07/Work/Fiverr/piousmusabaila/cardbot/recipies/app_icon.png", :position => :right, :width => 100, :height => 100
		end
		"/home/torq07/Work/Fiverr/piousmusabaila/cardbot/recipies/#{pdf_name}"
	end

	def deactivate_card
		text = 'Please enter card id for card deactivation'
		request(text: text, force_reply: true)	
	end

	def request_customer_id
		text = 'Please enter customer id'
		request(text: text, force_reply: true)	
	end

	def print_stats
		redeemed_text=''
		activated_text=''
		redeemed_cards=CardTransaction.where("trans_type = ? AND status = ?", 'redeem','done')
																	.pluck(:card_id)
																	.uniq
		activated_cards=Card.where(status:'activated')
		puts 'Redeemed cards'
		redeemed_cards.map{|t| Card.find(t)}
		activated_text = generate_text(activated_cards)
		redeemed_text = generate_text(redeemed_cards.map{|t| Card.find(t)})
		text="Redeemed Cards:\n\n#{redeemed_text}\n\n Activated Cards:\n\n#{activated_text}"
		request(text:text, answers:@answers)
	end	

	def generate_text(array)
		flyers,vouchers,cashs,loyals,coupons = 0,0,0,0,0
		array.each do |card|
			case card.card_product.type_name 
			when 'flyer' 
				flyers+=1
			when 'coupon' 
				coupons+=1
			when 'loyal' 
				loyals+=1
			when 'cash' 
				cashs+=1
			when 'voucher' 
				vouchers+=1
			end
		end
		"Flyers : #{flyers}\nVouchers: #{vouchers}\nCoupons #{coupons}\nLoyalty cards:#{loyals}\nCash cards#{cashs}"			
	end

end	