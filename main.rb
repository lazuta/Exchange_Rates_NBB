require 'telegram/bot'
require 'httparty'

TOKEN = '1236367507:AAGR_UsVtRjzy-UAYR0KdMbmX6VB5GjvYug'
API_NBB = 'https://www.nbrb.by/API/ExRates/Rates/'


Telegram::Bot::Client.run(TOKEN) do |bot|
    bot.listen do |message|
        case message
            when Telegram::Bot::Types::CallbackQuery
                case message.data
                    when 'rage'
                        url = API_NBB + "USD?parammode=2"
                        response = HTTParty.get(url)

                        text = "#{response["Cur_Scale"].to_f.round(3)} #{response["Cur_Abbreviation"]} = #{response["Cur_OfficialRate"].to_f.round(3)} BYR "

                        bot.api.send_message(
                            chat_id: message.from.id,
                            text: text
                        )

                    when 'list'
                        url = "https://www.nbrb.by/api/exrates/currencies"
                        response = HTTParty.get(url)

                        currency_code = Array.new
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
                            chat_id: message.from.id,
                            text: codies
                        )

                    when 'help'
                        text = "/rage CODE - Получение курса валюты по ее буквенному коду (CODE).\n/rage CODE SUM - Получение курса валюты по ее буквенному коду (CODE) и количеству (SUM)."

                        bot.api.send_message(
                            chat_id: message.from.id,
                            text: text
                        )
                end
            
            when Telegram::Bot::Types::Message
                msg = message.text
                msg_arr = msg.split(" ")

                case msg_arr[0]
                    when '/start'
                        kb = [
                            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Курс доллара', callback_data: 'rage'),
                            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Доступные коды валют',  callback_data: 'list'),
                            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Помощь', callback_data: 'help') 
                        ]

                        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
                        
                        bot.api.send_message(
                            chat_id: message.chat.id,
                            text: "Добро пожаловать, #{message.from.first_name}",
                            reply_markup: markup
                        )

                    when '/rage'
                        url = API_NBB + "#{msg_arr[1]}?parammode=2"
                        response = HTTParty.get(url)

                        if msg_arr.length == 2
                            text = "#{response["Cur_Scale"].to_f.round(3)} #{response["Cur_Abbreviation"]} = #{response["Cur_OfficialRate"].to_f.round(3)} BYR "

                            bot.api.send_message(
                                chat_id: message.chat.id,
                                text: text
                            )

                        elsif msg_arr.length == 3
                            count = msg_arr[2].to_f

                            req_currency = (response["Cur_Scale"].to_f / response["Cur_Scale"].to_f) * count
                            res_currency = (response["Cur_OfficialRate"].to_f / response["Cur_Scale"].to_f) * count

                            text = "#{ req_currency.to_f.round(3) } #{response["Cur_Abbreviation"]} = #{ res_currency.to_f.round(3) } BYR "
                        
                            bot.api.send_message(
                                chat_id: message.chat.id,
                                text: text
                            )
                        
                        end
                    
                    when '/help'
                        text = "/rage CODE - Получение курса валюты по ее буквенному коду (CODE).\n/rage CODE SUM - Получение курса валюты по ее буквенному коду (CODE) и количеству (SUM)."

                        bot.api.send_message(
                            chat_id: message.chat.id,
                            text: text
                        )

                    when '/list'
                        url = "https://www.nbrb.by/api/exrates/currencies"
                        response = HTTParty.get(url)

                        codies = ""

                        for code in response
                            # Ради этой строки я встал в 3 ночи, т.к. она тупо приснилась
                            if !codies.include? code["Cur_Abbreviation"]
                                codies += "#{code["Cur_Abbreviation"]} - #{code["Cur_Name"]}\n"
                            end 
                        end
                    
                        bot.api.send_message(
                            chat_id: message.chat.id,
                            text: codies
                        )

                    when '/stop'
                        kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)

                        bot.api.send_message(
                            chat_id: message.chat.id,
                            text: 'Жаль, что ты уходишь :(',
                            reply_markup: kb
                        )
                end
        end
    end
end
