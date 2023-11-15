local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local widgets = require("vicious.widgets.init")
local util = require("widgets.util")

local date = wibox.widget.textbox()
vicious.register(date, vicious.widgets.date, "%a %d/%m/%y %R")

return date
