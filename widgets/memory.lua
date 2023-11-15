local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local widgets = require("vicious.widgets.init")
local util = require("widgets.util")

local memory = wibox.widget.textbox()

vicious.cache(vicious.widgets.mem)

local update = function(widget, args)
   local total_mem = args[3] / 1024
   local used_mem = args[2] / 1024
   local total_swp = args[6] / 1024
   local used_swp = args[7] / 1024
   return ("Mem: %d/%d Swp: %d/%d"):format(used_mem, total_mem, total_swp, used_swp)
end

vicious.register(memory, vicious.widgets.mem, update, 13)

return memory
