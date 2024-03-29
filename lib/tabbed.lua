--[[

This module currently works by adding a new property to each client that is tabbed.
That new property is called tabbed. 
So each client in a tabbed state has the property "tabbed" which is a table.
Each client that is not tabbed doesn't have that property.
In the function themselves, the same object is refered to as "tabobj" which is why
you will often see something like: "local tabobj = some_client.tabbed" at the beginning
of a function.

--]]

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local utils = require("utils")

local bar = require("widgets.tabbar")

tabbed = {}

-- helper function to connect to the (un)focus signals
local function update_tabbar_from(c)
    if not c or not c.tabbed then
        return
    end
    tabbed.update_tabbar(c.tabbed)
end

-- used to change focused tab relative to the currently focused one
tabbed.iter = function(idx)
    if not idx then
        idx = 1
    end
    if not client.focus or not client.focus.tabbed then
        return
    end
    local tabobj = client.focus.tabbed
    local new_idx = (tabobj.focused_idx + idx) % #tabobj.clients
    if new_idx == 0 then
        new_idx = #tabobj.clients
    end
    tabbed.switch_to(tabobj, new_idx)
end

-- removes a given client from its tab object
tabbed.remove = function(c)
    if not c or not c.tabbed then
        return
    end
    local tabobj = c.tabbed
    table.remove(tabobj.clients, tabobj.focused_idx)
    if not beautiful.tabbar_disable then
        awful.titlebar.hide(c, bar.position)
    end
    c.tabbed = nil
    c:disconnect_signal("focus", update_tabbar_from)
    c:disconnect_signal("unfocus", update_tabbar_from)
    awesome.emit_signal("bling::tabbed::client_removed", tabobj, c)
    tabbed.switch_to(tabobj, 1)
end

-- removes the currently focused client from the tab object
tabbed.pop = function()
    if not client.focus or not client.focus.tabbed then
        return
    end
    tabbed.remove(client.focus)
end

-- adds a client to a given tabobj
tabbed.add = function(c, tabobj)
    if c.tabbed then
        tabbed.remove(c)
    end
    c:connect_signal("focus", update_tabbar_from)
    c:connect_signal("unfocus", update_tabbar_from)
    utils.client.sync(c, tabobj.clients[tabobj.focused_idx])
    tabobj.clients[#tabobj.clients + 1] = c
    tabobj.focused_idx = #tabobj.clients
    -- calls update even though switch_to calls update again
    -- but the new client needs to have the tabobj property
    -- before a clean switch can happen
    tabbed.update(tabobj)
    awesome.emit_signal("bling::tabbed::client_added", tabobj, c)
    tabbed.switch_to(tabobj, #tabobj.clients)
end

-- use xwininfo to select one client and make it tab in the currently focused tab
tabbed.pick = function()
    if not client.focus then
        return
    end
    -- this function uses xwininfo to grab a client window id which is then
    -- compared to all other clients window ids

    local xwininfo_cmd =
        [[ xwininfo | grep 'xwininfo: Window id:' | cut -d " " -f 4 ]]
    awful.spawn.easy_async_with_shell(xwininfo_cmd, function(output)
        for _, c in ipairs(client.get()) do
            if tonumber(c.window) == tonumber(output) then
                if not client.focus.tabbed and not c.tabbed then
                    tabbed.init(client.focus)
                    tabbed.add(c, client.focus.tabbed)
                end
                if not client.focus.tabbed and c.tabbed then
                    tabbed.add(client.focus, c.tabbed)
                end
                if client.focus.tabbed and not c.tabbed then
                    tabbed.add(c, client.focus.tabbed)
                end
                -- TODO: Should also merge tabs when focus and picked
                -- both are tab groups
            end
        end
    end)
end

-- select a client by direction and make it tab in the currently focused tab
tabbed.pick_by_direction = function(direction)
    local sel = client.focus
    if not sel then
        return
    end
    if not sel.tabbed then
        tabbed.init(sel)
    end
    local c = utils.client.get_by_direction(direction)
    if not c then
        return
    end
    tabbed.add(c, sel.tabbed)
end

-- use dmenu to select a client and make it tab in the currently focused tab
tabbed.pick_with_dmenu = function(dmenu_command)
    if not client.focus then
        return
    end

    if not dmenu_command then
        dmenu_command = "rofi -dmenu -i"
    end

    -- get all clients from the current tag
    -- ignores the case where multiple tags are selected
    local t = awful.screen.focused().selected_tag
    local list_clients = {}
    local list_clients_string = ""
    for idx, c in ipairs(t:clients()) do
        if c.window ~= client.focus.window then
            list_clients[#list_clients + 1] = c
            if #list_clients ~= 1 then
                list_clients_string = list_clients_string .. "\\n"
            end
            list_clients_string = list_clients_string
                .. tostring(c.window)
                .. " "
                .. c.name
        end
    end

    if #list_clients == 0 then
        return
    end
    -- calls the actual dmenu
    local xprop_cmd = [[ echo -e "]]
        .. list_clients_string
        .. [[" | ]]
        .. dmenu_command
        .. [[ | awk '{ print $1 }' ]]
    awful.spawn.easy_async_with_shell(xprop_cmd, function(output)
        for _, c in ipairs(list_clients) do
            if tonumber(c.window) == tonumber(output) then
                if not client.focus.tabbed then
                    tabbed.init(client.focus)
                end
                local tabobj = client.focus.tabbed
                tabbed.add(c, tabobj)
            end
        end
    end)
end

-- update everything about one tab object
tabbed.update = function(tabobj)
    local currently_focused_c = tabobj.clients[tabobj.focused_idx]
    -- update tabobj of each client and other things
    for idx, c in ipairs(tabobj.clients) do
        if c.valid then
            c.tabbed = tabobj
            utils.client.sync(c, currently_focused_c)
            -- the following handles killing a client while the client is tabbed
            c:connect_signal("unmanage", function(c)
                tabbed.remove(c)
            end)
        end
    end

    -- Maybe remove if I'm the only one using it?
    awesome.emit_signal("bling::tabbed::update", tabobj)
    if not beautiful.tabbar_disable then
        tabbed.update_tabbar(tabobj)
    end
end

-- change focused tab by absolute index
tabbed.switch_to = function(tabobj, new_idx)
    local old_focused_c = tabobj.clients[tabobj.focused_idx]
    tabobj.focused_idx = new_idx
    for idx, c in ipairs(tabobj.clients) do
        if idx ~= new_idx then
            utils.client.turn_off(c)
        else
            utils.client.turn_on(c)
            c:raise()
            if old_focused_c and old_focused_c.valid then
                c:swap(old_focused_c)
            end
            utils.client.sync(c, old_focused_c)
        end
    end
    awesome.emit_signal("bling::tabbed::changed_focus", tabobj)
    tabbed.update(tabobj)
end

tabbed.update_tabbar = function(tabobj)
    local flexlist = bar.layout()
    local tabobj_focused_client = tabobj.clients[tabobj.focused_idx]
    local tabobj_is_focused = (client.focus == tabobj_focused_client)
    -- itearte over all tabbed clients to create the widget tabbed list
    for idx, c in ipairs(tabobj.clients) do
        local buttons = gears.table.join(awful.button({}, 1, function()
            tabbed.switch_to(tabobj, idx)
        end))
        local wid_temp = bar.create(c, (idx == tabobj.focused_idx), buttons,
            not tabobj_is_focused)
        flexlist:add(wid_temp)
    end
    -- add tabbar to each tabbed client (clients will be hided anyway)
    if not beautiful.tabbar_disable then
        for _, c in ipairs(tabobj.clients) do
            local titlebar = awful.titlebar(c, {
                bg = bar.bg_normal,
                size = bar.size,
                position = bar.position,
            })
            titlebar:setup({ layout = wibox.layout.flex.horizontal, flexlist })
        end
    end
end

tabbed.init = function(c)
    local tabobj = {}
    tabobj.clients = { c }
    c:connect_signal("focus", update_tabbar_from)
    c:connect_signal("unfocus", update_tabbar_from)
    tabobj.focused_idx = 1
    tabbed.update(tabobj)
end

tabbed.create = function()
   if client.focus.tabbed or not client.focus then
      return
   end
   tabbed.init(client.focus)
end

tabbed.spawn_in_tab = function()
    client.connect_signal("manage", function(c)
        local s = awful.screen.focused()
        local previous_client = awful.client.focus.history.get(s, 1)
        if previous_client and previous_client.tabbed then
            tabbed.add(c, previous_client.tabbed)
        end
    end)
end

return tabbed
