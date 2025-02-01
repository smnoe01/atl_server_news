-- Definition des variables
local atl_server_news = {
    modpath = minetest.get_modpath("atl_server_news"),
    mod_storage = minetest.get_mod_storage()
}

-- Traduction (fr, en, it, es, ru)
local S = minetest.get_translator("atl_server_news")

----------
-- Definition des fonctions d'enregistrement
----------

-- Cree le fichier s'il n'existe pas
function atl_server_news.ensure_news_file_exists()
    if atl_server_news.mod_storage:get_string("news_content") == "" then
        atl_server_news.mod_storage:set_string("news_content", "")
        minetest.log("action", "Created news content in mod_storage.")
    else
        minetest.log("action", "News content already exists in mod_storage.")
    end
end

-- Lit le contenu du fichier
function atl_server_news.read_news_file()
    return atl_server_news.mod_storage:get_string("news_content")
end

-- Verifie si un joueur a dejà lu les dernieres news 
function atl_server_news.has_read_news(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end
    local player_meta = player:get_meta()
    local last_news_read = player_meta:get_string("last_news_read")
    local current_news = atl_server_news.read_news_file()
    return last_news_read == current_news
end

-- Marque les news comme lues pour un joueur
function atl_server_news.set_news_read(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end
    local player_meta = player:get_meta()
    local current_news = atl_server_news.read_news_file()
    player_meta:set_string("last_news_read", current_news)
end

-- Envoie une notification au joueur s'il y a de nouvelles news
function atl_server_news.send_news_notification(player_name)
    minetest.chat_send_player(player_name, S("[ ! ] There are new features on the server! Type /news to read them."))
end

-- Notifie un joueur des nouvelles news s'il ne les a pas encore lues
function atl_server_news.notify_new_news(player_name)
    if not atl_server_news.has_read_news(player_name) then
        atl_server_news.send_news_notification(player_name)
    end
end

-- Sauvegarde les nouvelles news
function atl_server_news.save_news(content)
    if not content then
        minetest.log("error", "Content is nil. Cannot save news content.")
        return
    end
    atl_server_news.mod_storage:set_string("news_content", content)
    minetest.log("action", "Saved news content in mod_storage.")
end

-- Initialisation fu fichier
function atl_server_news.init()
    atl_server_news.ensure_news_file_exists()
end

----------
-- Definition des formspecs
----------

-- Affiche la fs des news
function atl_server_news.show_news_form(player_name)
    atl_server_news.ensure_news_file_exists()
    local news_content = atl_server_news.read_news_file()
    local formspec = "size[6,8]" ..
                     "tabheader[0,0;tabs_news;Server News,Edit News (Admin Only);1;false;false]" ..
                     "box[0,0;5.80,8.1;#000000]" ..
                     "hypertext[0.5,0.15;5.5,8.65;news;<style size=16>" .. minetest.formspec_escape(news_content) .. "</style>]"
    minetest.show_formspec(player_name, "server_news", formspec)
end

-- Affiche la fs d'edition des news
function atl_server_news.show_edit_news_form(player_name)
    local news_content = atl_server_news.read_news_file()
    local formspec = "size[6,8]" ..
                     "tabheader[0,0;tabs_news;Server News,Edit News (Admin Only);2;false;false]" ..
                     "textarea[0.5,0.5;5.5,7.5;news_content;Edit News:;" .. news_content .. "]" ..
                     "button[2,7;2,1;save;Save]"
    minetest.show_formspec(player_name, "server_news_edit", formspec)
end

----------
-- Definition des commandes
----------

-- Definition de la commande /news
minetest.register_chatcommand("news", {
    description = "Show server news",
    privs = {shout = true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, S("[ ! ] Player does not exist")
        end
        atl_server_news.show_news_form(name)
        if not atl_server_news.has_read_news(name) then
            atl_server_news.set_news_read(name)
        end
        return true
    end,
})

----------
-- Definition de la gestion des evenement
----------

-- Gestion des evenements de formulaire
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if fields.save then
        atl_server_news.save_news(fields.news_content)
        minetest.chat_send_player(player:get_player_name(), S("[ ! ] Server news updated successfully."))
    end
    if fields.tabs_news == "2" then
        if minetest.check_player_privs(player, {server = true}) then
            atl_server_news.show_edit_news_form(player:get_player_name())
        else
            atl_server_news.show_news_form(player:get_player_name())
            minetest.chat_send_player(player:get_player_name(), S("[ ! ] You don't have permission to open this (missing privileges: server)"))
        end
    end
    if fields.tabs_news == "1" and minetest.check_player_privs(player, {server = true}) then
        atl_server_news.show_news_form(player:get_player_name())
    end
end)

-- Notifie les joueurs des nouvelles news lorsqu'ils rejoignent le serveur
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    atl_server_news.notify_new_news(player_name)
end)

-- Initialisation
atl_server_news.init()