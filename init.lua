local modpath = core.get_modpath("atl_server_news")
local mod_storage = core.get_mod_storage()
local S = core.get_translator("atl_server_news")

core.register_privilege("server_news_edit", {
    description = "Allows editing of server news",
    give_to_singleplayer = false
})

local function ensure_storage()
    if mod_storage:get_string("news_content") == "" then
        mod_storage:set_string("news_content", "")
    end
    if not mod_storage:get_int("news_read_count") then
        mod_storage:set_int("news_read_count", 0)
    end
end

local function read_news()
    return mod_storage:get_string("news_content")
end

local function get_read_count()
    return mod_storage:get_int("news_read_count")
end

local function has_read(name)
    local player = core.get_player_by_name(name)
    if not player then return false end
    local meta = player:get_meta()
    return meta:get_string("last_news_read") == read_news()
end

local function set_read(name)
    if not has_read(name) then
        local player = core.get_player_by_name(name)
        if not player then return end
        player:get_meta():set_string("last_news_read", read_news())
        local count = mod_storage:get_int("news_read_count")
        mod_storage:set_int("news_read_count", count + 1)
    end
end

local function send_notification(name)
    core.chat_send_player(name, S("[ ! ] New server news available! Type /news to read."))
end

local function notify_on_join(name)
    local news = read_news()
    if news == "" then return end
    if not has_read(name) then
        send_notification(name)
    end
end

local function save_news(content)
    if not content then return end
    mod_storage:set_string("news_content", content)
    mod_storage:set_int("news_read_count", 0)
    core.log("action", "News updated; read count reset to 0.")
end

local function show_news_form(name)
    ensure_storage()
    set_read(name)

    local raw = read_news()
    local display = raw == "" and S("No news available") or raw
    local news = core.formspec_escape(display)
    local count = get_read_count()
    local is_admin = core.check_player_privs(name, {server_news_edit=true})
    local tabs = is_admin and "News,Edit News" or "News"
    local formspec = "size[7,9]" ..
                     "tabheader[0,0;tabs;" .. tabs .. ";1;false;false]" ..
                     "box[0,0;6.8,8.75;#000000]" ..
                     "hypertext[0.5,0.15;5.5,8.65;content;<style size=16>" .. news .. "</style>]" ..
                     "label[0,8.8;Players who have seen the recent news " .. count .. "]"
    core.show_formspec(name, "atl_news", formspec)
end

local function show_edit_form(name)
    local content = read_news()
    local formspec = "size[7,9]" ..
                     "tabheader[0,0;tabs;News,Edit News;2;false;false]" ..
                     "textarea[0.5,0.5;6.5,8.5;news_text;Edit News;" .. core.formspec_escape(content) .. "]" ..
                     "button[2.5,8;2,1;save_server_news;Save]"
    core.show_formspec(name, "atl_news_edit", formspec)
end

core.register_chatcommand("news", {
    description = "Show server news",
    privs = {shout=true},
    func = function(name)
        show_news_form(name)
        return true
    end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname == "atl_news_edit" and fields.save_server_news then
        save_news(fields.news_text or "")
        core.chat_send_player(name, S("[ ! ] News updated. Read count reset to 0."))
        return
    end
    if fields.tabs then
        if fields.tabs == "1" then
            show_news_form(name)
        elseif fields.tabs == "2" then
            if core.check_player_privs(name, {server_news_edit=true}) then
                show_edit_form(name)
            else
                show_news_form(name)
                core.chat_send_player(name, S("[ ! ] You lack the server_news_edit privilege."))
            end
        end
    end
end)

core.register_on_joinplayer(function(player)
    notify_on_join(player:get_player_name())
end)

ensure_storage()
