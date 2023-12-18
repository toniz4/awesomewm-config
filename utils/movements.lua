local awful = require("awful")
local tabbed = require("lib.tabbed")
local widgets = require("widgets")

local movements = {}

movements.mode_widget = widgets.mode

movements.mode = "normal"

local function update_mode_widget()
   movements.mode_widget:set_markup(movements.mode)
end

movements.set_mode = function(mode)
   movements.mode = mode
   update_mode_widget()
end

movements.exit_mode = function()
   movements.mode = "normal"
   update_mode_widget()
end

movements.focus = function(idx)
   local next_client = awful.client.next(idx)
   client.focus = next_client
   client.focus:raise()
end

movements.swap = function(idx)
   local next_client = awful.client.next(idx)

   if next_client.tabbed then
      tabbed.add(client.focus, next_client.tabbed)
   else
      client.focus:swap(next_client)
   end
end

movements.right = function()
   if movements.mode == "normal" then
      tabbed.iter(1)
   elseif movements.mode == "resize" then
      awful.tag.incmwfact(0.05)
   end
end

movements.pop = function()
   -- local next_client = awful.client.next(1)
   local c = client.focus
   tabbed.remove(c)
   -- c:swap(client.focus)
   -- client.focus = c
   -- c:swap(next_client)
end

movements.left = function()
   if movements.mode == "normal" then
      tabbed.iter(-1)
   elseif movements.mode == "resize" then
      awful.tag.incmwfact(-0.05)
   end
end

return movements
