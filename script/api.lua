function atl_server_news.open_file(path, mode)
    local file = io.open(path, mode)
    if not file then
        minetest.log("error", "Impossible to open file: " .. path)
    end
    return file
end

function atl_server_news.ensure_news_file_exists()
    local file = atl_server_news.open_file(atl_server_news.news_file_path, "r")
    if not file then
        file = atl_server_news.open_file(atl_server_news.news_file_path, "w")
        if file then
            file:write("")
            file:close()
        else
            minetest.log("error", "Impossible to create news.txt file.")
        end
    else
        file:close()
    end
end

function atl_server_news.read_news_file()
    local file = atl_server_news.open_file(atl_server_news.news_file_path, "r")
    if not file then
        return ""
    end
    local content = file:read("*all")
    file:close()
    return content
end

function atl_server_news.has_read_news(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    local player_meta = player:get_meta()
    local last_news_read = player_meta:get_string("last_news_read")
    local current_news = atl_server_news.read_news_file()
    return last_news_read == current_news
end

function atl_server_news.set_news_read(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end
    local player_meta = player:get_meta()
    local current_news = atl_server_news.read_news_file()
    player_meta:set_string("last_news_read", current_news)
end

function atl_server_news.send_news_notification(player_name)
    minetest.chat_send_player(player_name, "-!- There are new features on the server! Type /news to read them.")
end

function atl_server_news.notify_new_news(player_name)
    if not atl_server_news.has_read_news(player_name) then
        atl_server_news.send_news_notification(player_name)
    end
end

function atl_server_news.save_news(content)
    local file = atl_server_news.open_file(atl_server_news.news_file_path, "w")
    if file then
        file:write(content)
        file:close()
    else
        minetest.log("error", "Impossible to save news.txt file.")
    end
end

function atl_server_news.init()
    atl_server_news.ensure_news_file_exists()
end

minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    atl_server_news.notify_new_news(player_name)
end)

atl_server_news.init()
