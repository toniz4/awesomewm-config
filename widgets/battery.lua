local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local util = require("widgets.util")
local vicious = require("vicious")
local naughty = require("naughty")

local battery = util.styled_textarea()

local notified = false

local notify_battery = function(charge)
   if not notified and charge < 20 then
      notified = true
      naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Low Battery",
            text = "Battery at " .. charge .. "%"
      })
   end

   if notified and charge > 20 then
      notified = false
   end
end

local update = function(widget, args)
   notify_battery(args[2])
   return args[1] .. " " .. args[2] .. "%"
end

vicious.register(battery, vicious.widgets.bat, update, 61, "BAT0")

return battery
