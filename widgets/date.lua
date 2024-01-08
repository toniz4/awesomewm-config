local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local widgets = require("vicious.widgets.init")
local util = require("widgets.util")
local helpers = require("vicious.helpers")

local calendar = wibox.widget.calendar.month(os.date('*t'))

local datetime = helpers.setcall(function (format, warg)
      local default_locale = os.setlocale(nil)
      os.setlocale('pt_BR.UTF-8')
      local date = os.date(format or nil, warg and os.time()+warg or nil)
      os.setlocale(default_locale)
    return date
end)

local date = util.styled_textarea()
local month_calendar = awful.widget.calendar_popup.month({spacing = 10})

month_calendar:attach( date, "br" )

vicious.register(date, datetime, "%a %d/%m/%y %R")

return date
