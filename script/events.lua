minetest.register_on_player_receive_fields(function(player, formname, fields)
    if fields.save then
        atl_server_news.save_news(fields.news_content)
        minetest.chat_send_player(player:get_player_name(), "-!- Server news updated successfully.")
    end
    if fields.tabs == "2" and minetest.check_player_privs(player, {server = true}) then
        atl_server_news.show_edit_news_form(player:get_player_name())
    end
    if fields.tabs == "1" and minetest.check_player_privs(player, {server = true}) then
        atl_server_news.show_news_form(player:get_player_name())
    end
end)

minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    atl_server_news.notify_new_news(player_name)
end)