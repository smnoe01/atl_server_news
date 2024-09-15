function atl_server_news.show_news_form(player_name)
    atl_server_news.ensure_news_file_exists()
    local news_content = atl_server_news.read_news_file()
    local formspec = "size[9,6]" ..
                     "tabheader[0,0;tabs;   Server News   ,   Edit News (Admin Only)   ;1;false;false]" ..
                     "box[0,0;8.80,6.1;#000000]" ..
                     "hypertext[0.5,0.15;8.5,6.65;news;<style size=16>" .. minetest.formspec_escape(news_content) .. "</style>]"
    minetest.show_formspec(player_name, "server_news", formspec)
end

function atl_server_news.show_edit_news_form(player_name)
    local news_content = atl_server_news.read_news_file()
    local edit_formspec = "size[9,6]" ..
                          "tabheader[0,0;tabs;   Server News   ,   Edit News (Admin Only)   ;2;false;false]" ..
                          "textarea[0.5,0.5;8.5,4.5;news_content;Edit News:;" .. news_content .. "]" ..
                          "button[3.5,5.5;2,1;save;Save]"
    minetest.show_formspec(player_name, "server_news_edit", edit_formspec)
end