class ReplyMarkupFormatter
  attr_reader :array

  def initialize(array,formating = false)
    @array = array
    @formating = formating
  end

  def get_markup
    hash = if @formating
      { keyboard: array, resize_keyboard: true }
    else
      { keyboard: array.each_slice(2).to_a, resize_keyboard: true }
    end  
    p hash
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(hash)
  end

  def get_inline_markup
    hash = if  @formating
      { inline_keyboard: array.to_a }
    else
      { inline_keyboard: array.each_slice(2).to_a }
    end  
  	Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: array.each_slice(2).to_a)
  end
  
  def get_force_reply
    Telegram::Bot::Types::ForceReply.new(force_reply: true)      
  end

  def get_contact_request(button_text)
    kb = array.each_slice(2).to_a
    kb << Telegram::Bot::Types::KeyboardButton.new(text: button_text, 
           request_contact: true)                                           
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, 
      resize_keyboard: true)     
  end  
  
  def get_location_request(button_text)
    kb = array.each_slice(2).to_a
    kb << Telegram::Bot::Types::KeyboardButton.new(text: button_text, 
            request_location: true)
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb,
       resize_keyboard: true)     
  end 
    
end
