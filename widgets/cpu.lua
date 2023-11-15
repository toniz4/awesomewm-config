local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local widgets = require("vicious.widgets.init")
local util = require("widgets.util")

local cpu_usage = util.labeled_graph("CPUu", 100)
vicious.register(cpu_usage, vicious.widgets.cpu, "$1", 3)

local usage_tooltip = awful.tooltip {}
usage_tooltip:add_to_object(cpu_usage)

function usage_tooltip_format()
   local output = widgets.cpu()
   local text = ""
   for i in pairs(output) do
      if i > 1 then
         text = text .. "#" .. i - 1 .. " " .. tostring(output[i]) .. "%"
      else
         text = text .. "Total: " .. tostring(output[i]) .. "%"
      end

      if i ~= #output then
         text = text .. "\n"
      end
   end
   return text
end

cpu_usage:connect_signal('mouse::enter',
                         function()
                            usage_tooltip.text = usage_tooltip_format()
                         end)

local cpu_monitor = {"coretemp"}

local cpu_temp = util.labeled_graph("CPUt", 100)
vicious.register(cpu_temp, vicious.widgets.hwmontemp, "$1", 1, cpu_monitor)

local temp_tooltip = awful.tooltip {}
temp_tooltip:add_to_object(cpu_temp)

cpu_temp:connect_signal('mouse::enter',
                         function()
                            output = widgets.hwmontemp(nil, cpu_monitor)[1]
                            temp_tooltip.text = tostring(output) .. "°C"
                         end)

return {
   usage = cpu_usage,
   temp = cpu_temp
}
