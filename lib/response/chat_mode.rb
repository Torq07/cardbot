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
  					text = 'Please tell me customer cell number'
  					request(text: text, force_reply:true)
  				else	
  					request_redeem_value 
  				end	
  			else
  				request(text:"Sorry there is no card with such id",answers:@answers)
  			end	
  		when 'Please tell me customer cell number'
  			customer_id = message.text.strip.to_i
  			Customer.find_or_create_by(id:customer_id)
  			user.card_transactions.last.card.update_attribute(:customer_id, customer_id)
  			text = 'Please tell me customer first name'
				request(text: text, force_reply:true)
  		when 'Please tell me customer first name'
  			name = message.text.strip
  			customer = Customer.find(user.card_transactions.last.card.customer_id)
  			customer.update_attribute(:first_name, name)
  			text = 'Please tell me customer second name'
				request(text: text, force_reply:true)
  		when 'Please tell me customer second name'
  			second_name = message.text.strip
  			customer = Customer.find(user.card_transactions.last.card.customer_id)
  			customer.update_attribute(:last_name, second_name)
  			text = 'Please enter amount the transacted'
				request(text: text, force_reply:true)
  		when 'Please enter amount the transacted'
  			user.card_transactions.last.update_attribute(:amount, -1*message.text.strip.to_i)
  			run_trunsactions
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
  				request(text:"Card balance is : $#{sprintf('%.2f', balance)}",answers:@answers)
  			else
  				request(text:"Sorry there is no card with such id",answers:@answers)
  			end	
  		end
	  elsif message.text
	    case message.text
	      when '/start'
	        answer_with_greeting_message
	      when /Redeem Value||\/redeem/i
	      	redeem_value
				when /Check Balance||\/balance/i
					check_balance
				when /Activate Card||\/activate/i
					activate_card
				when /Deactivate Card||\/deactivate/i
					deactivate_card 
				when /\/print/i
					print_stats
				else 
					request(text:"Valid commands are /redeem, /activate, /balance, /print and /deactivate", answers: @answers)
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
				redeem_succesful(t.card,t.amount)
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

	def redeem_succesful(card,amount)
		cid = card.customer_id||"not assigned"
		balance = card.balance
		card_id = card.id
		store_name = Store.find(card.store_id).store_name
		expire = card.expiring_date
		text="Redemption Successful\n"+
				 "Cust id: #{cid}\n"+
				 "Card No: #{card_id}\n"+
				 "Store name: #{store_name}\n"+
				 "New Balance $#{sprintf('%.2f', balance)}\n"+
				 "This Card will expire on #{expire}"
		receipt_array = [
			[:image,["/home/torq07/Work/Fiverr/piousmusabaila/cardbot/recipies/app_icon.png", :position => :center, :width => 150, :height => 150]],
			[:move_down,40],
			[:text,["Redemption receipt",{:align => :center, :size => 40}]],
			[:text,["Date: #{Time.now.strftime("%Y/%m/%d %H:%M")}", {:align => :center, :size => 34}]],
			[:move_down,20],
			[:text,["Store Name: #{store_name}", {:size => 28}]],
			[:stroke_horizontal_rule],
			[:move_down,20],
			[:text,["Cust id: #{cid}",{:size => 28}]],
			[:stroke_horizontal_rule],
			[:move_down,20],
			[:text,["Card No: #{card.id}", {:size => 28}]],
			[:stroke_horizontal_rule],
			[:move_down,20],
			[:text,["Redeemed amount: $#{sprintf('%.2f', amount.abs)}", {:size => 28}]],
			[:stroke_horizontal_rule],
			[:move_down,20],
			[:text,["New Balance: $#{sprintf('%.2f', card.balance)}", {:size => 28}]],
			[:stroke_horizontal_rule],
			[:move_down,20],
			[:text,["This Card will expire on #{card.expiring_date}", {:size => 28}]],
			[:stroke_horizontal_rule],
			[:move_down,60],
			[:text,["You can check your voucher balance by texting balance to giglea using facebook messenger", {:size => 24}]],
		]
		time_now=Time.now.strftime("%Y_%m_%d_%H_%M")
		pdf_name="Card_#{card.id}_#{time_now}.pdf"
		pdf=generate_pdf(pdf_name,receipt_array)
		request(text:text,answers:@answers)
		MessageSender.new(bot:bot, chat: message.from, document:pdf).send_document
	end

	def generate_pdf(name,text_array)
		Prawn::Document.generate("/home/torq07/Work/Fiverr/piousmusabaila/cardbot/recipies/#{name}") do
			text_array.each do |k|
				send(k[0],*k[1])
			end	
		end
		"/home/torq07/Work/Fiverr/piousmusabaila/cardbot/recipies/#{name}"
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
		print_array = [
			[:image,["/home/torq07/Work/Fiverr/piousmusabaila/cardbot/recipies/app_icon.png", :position => :center, :width => 150, :height => 150]],
			[:move_down,40],
			[:text,["Activated Cards",{:align => :center, :size => 40}]],
			[:text,[activated_text,{:align => :left, :size => 30}]],
			[:stroke_horizontal_rule],
			[:move_down,40],
			[:text,["Redeemed Cards",{:align => :center, :size => 40}]],
			[:text,[redeemed_text,{:align => :left, :size => 30}]]
		]
		time_now=Time.now.strftime("%Y_%m_%d_%H_%M")
		name="Stats_#{time_now}.pdf"
		pdf=generate_pdf(name,print_array)
		MessageSender.new(bot:bot, chat: message.from, document:pdf).send_document
	end	

	def generate_text(array)
		flyers,vouchers,cashs,loyals,coupons = [0,0],[0,0],[0,0],[0,0],[0,0]
		array.each do |card|
			case card.card_product.type_name 
			when 'flyer' 
				flyers[0]+=1
				flyers[1]+=card.balance
			when 'coupon' 
				coupons[0]+=1
				coupons[1]+=card.balance
			when 'loyal' 
				loyals[0]+=1
				loyals[1]+=card.balance
			when 'cash' 
				cashs[0]+=1
				cashs[1]+=card.balance
			when 'voucher' 
				vouchers[0]+=1
				vouchers[1]+=card.balance
			end
		end
		"Flyers : #{flyers[0]} $#{sprintf('%.2f', flyers[1])}\n"+
		"Vouchers: #{vouchers[0]} $#{sprintf('%.2f', vouchers[1])}\n"+
		"Coupons: #{coupons[0]} $#{sprintf('%.2f', coupons[1])}\n"+
		"Loyalty cards: #{loyals[0]} $#{sprintf('%.2f', loyals[1])}\n"+
		"Cash cards: #{cashs[0]} $#{sprintf('%.2f', cashs[1])}"			
	end

end	