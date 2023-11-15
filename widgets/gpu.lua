local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local widgets = require("vicious.widgets.init")
local util = require("widgets.util")

local gpu_monitor = {"amdgpu"}

local gpu_temp = util.labeled_graph("GPUt", 100)
vicious.register(gpu_temp, vicious.widgets.hwmontemp, "$1", 1, gpu_monitor)

local temp_tooltip = awful.tooltip {}
temp_tooltip:add_to_object(gpu_temp)

gpu_temp:connect_signal('mouse::enter',
                         function()
                            output = widgets.hwmontemp(nil, gpu_monitor)[1]
                            temp_tooltip.text = tostring(output) .. "°C"
                         end)

return {
   temp = gpu_temp
}
