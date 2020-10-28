require 'telegram/bot'
require 'httparty'

TOKEN = ''
API_NBB = 'https://www.nbrb.by/API/ExRates/Rates/'
# API_Digital = ""

Telegram::Bot::Client.run(TOKEN) do |bot|
    bot.listen do |message|

        msg = message.text
        msg_arr = msg.split(" ")

        case msg_arr[0]
            when '/start'
                bot.api.send_message(
                    chat_id: message.chat.id,
                    text: "Добро пожаловать, #{message.from.first_name}"
                )

            when '/rage'

                url = API_NBB + "#{msg_arr[1]}?parammode=2"
                response = HTTParty.get(url)

                if msg_arr.length == 2
                    text = "#{response["Cur_Scale"]} #{response["Cur_Abbreviation"]} = #{response["Cur_OfficialRate"]} BYR "
                
                    bot.api.send_message(
                        chat_id: message.chat.id,
                        text: text
                    )
                elsif msg_arr.length == 3   

                    count = msg_arr[2].to_f

                    text = "#{(response["Cur_Scale"].to_f / response["Cur_Scale"].to_f) * count} #{response["Cur_Abbreviation"]} = #{(response["Cur_OfficialRate"].to_f / response["Cur_Scale"].to_f) * count} BYR "
                
                    bot.api.send_message(
                        chat_id: message.chat.id,
                        text: text
                    )
                end

            when '/list'
                bot.api.send_message(
                    chat_id: message.chat.id,
                    text: "---"
                )
        end
    end
end

# for code in CODIES
#     if "/rate #{code}" == message.text
#         url = API_NBB + code + API_Digital
#         response = HTTParty.get(url)
        
#         $message = "#{response["Cur_Scale"]} #{response["Cur_Abbreviation"]} = #{response["Cur_OfficialRate"]} BYR "

#         bot.api.send_message(
#             chat_id: message.chat.id,
#             text: $message
#         )
#     else
        
#     end
# end