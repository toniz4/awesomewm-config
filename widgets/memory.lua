local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local widgets = require("vicious.widgets.init")
local util = require("widgets.util")

local memory = util.styled_textarea()

vicious.cache(vicious.widgets.mem)

local update = function(widget, args)
   local gb = 1000
   local total_mem = args[3] / gb
   local used_mem = args[2] / gb
   local total_swp = args[6] / gb
   local used_swp = args[7] / gb
   return ("󰍛 %dGB/%dGB %dGB/%dGB"):format(used_mem, total_mem, total_swp, used_swp)
end

vicious.register(memory, vicious.widgets.mem, update, 13)

return memory
