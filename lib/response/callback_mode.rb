Dir['./models/*'].each {|file| require file unless File.directory?(file)} 
Dir['./lib/*'].each {|file| require file unless File.directory?(file) }


class CallbackMode

  include MainRequests
	
	attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = options[:user]
  end
	 
  def response
	  case message.data
	    when /start/i
	  end 
	end 

end	