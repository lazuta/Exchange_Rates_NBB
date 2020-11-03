def rageTwo(res, message)
    text = "#{res["Cur_Scale"].to_f.round(3)} #{res["Cur_Abbreviation"]} = #{res["Cur_OfficialRate"].to_f.round(3)} BYR "

    bot.api.send_message(
        chat_id: message.chat.id,
        text: text
    )
end