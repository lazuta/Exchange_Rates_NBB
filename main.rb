require 'telegram/bot'
require 'httparty'

TOKEN = '1236367507:AAGR_UsVtRjzy-UAYR0KdMbmX6VB5GjvYug'
API_NBB = 'https://www.nbrb.by/API/ExRates/Rates/'

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
                url = "https://www.nbrb.by/api/exrates/currencies"
                response = HTTParty.get(url)

                codies = ""

                for code in response              
                    add_mode = true

                    for currency in currency_code
                        if code["Cur_Abbreviation"] == currency
                            add_mode = false
                        end
                    end 

                    if add_mode
                        codies += "#{code["Cur_Abbreviation"]} - #{code["Cur_Name"]}\n"
                    end 

                    currency_code.push(code["Cur_Abbreviation"])
                end

            
                bot.api.send_message(
                    chat_id: message.chat.id,
                    text: codies
                )
        end
    end
end
