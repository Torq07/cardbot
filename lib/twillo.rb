require 'twilio-ruby'

class Twillo

	account_sid = 'AC1d6100472a29b55bea105f020ebf10f6'
	auth_token = '2edf7511f04c0732bc12bb7139c5b3ed'
	@client = Twilio::REST::Client.new account_sid, auth_token

	def self.send(number,body)
		@client.messages.create(
		  from: '+14423337011',
		  to: number,
		  body: body
		)
	rescue
		nil	
	end

end
# Usage example
# Twillo.send('+13473346669','Another test, sorry')