local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local util = require("widgets.util")
local vicious = require("vicious")

local battery = util.styled_textarea()

vicious.register(battery, vicious.widgets.bat, "$1 $2%", 61, "BAT0")

return battery
