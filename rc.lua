pcall(require, "luarocks.loader")
local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

naughty.config.defaults.border_width = beautiful.notification_border_width

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
local widgets = require("widgets")
local helpers = require("helpers")
local utils = require("utils")
local wpctl = utils.wpctl
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local movements = require("utils.movements")

function client_menu ()
   clients = {}
   for i, c in pairs(client.get()) do
      if not awful.rules.match_any(c, {instance = { "scratch", "umpv", "music"}}) then
	 clients[i] =
	    {c.name,
	     function()
		c.first_tag:view_only()
		client.focus = c
	     end,
	     c.icon
	    }
      end
   end
   awful.menu(clients):show()
end

-- Notifications


function naughty.config.notify_callback(args)
  local c = client.focus
  if c then
     if c.fullscreen and args.timeout ~= 0 then
	naughty.suspend()
	return
     else
	naughty.resume()
	return args
     end
  end
end

-- Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

-- Variable definitions
terminal = "xst"
modkey = "Mod4"

-- Layouts

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

menubar.utils.terminal = terminal

mykeyboardlayout = awful.widget.keyboardlayout()

mytextclock = wibox.widget.textclock()

function set_wallpaper()
   if beautiful.wallpaper then
      local wallpaper = beautiful.wallpaper

      if not gears.filesystem.file_readable(wallpaper) then
	 gears.wallpaper.set(wallpaper)
	 return
      end

      surf = gears.surface.load_uncached(wallpaper)

      local w, h = gears.surface.get_size(surf)

      -- If the image is small, tile it
      if w < 500 or h < 500 then
	 gears.wallpaper.tiled(surf)
      else
	 gears.wallpaper.maximized(surf, nil, true)
      end
   end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper

      -- Set monocle layout for the first tag
      awful.tag.add("1", {
		       layout = awful.layout.suit.max,
		       layouts = awful.layout.layouts,
		       screen = s,
		       selected = true
      })

      -- Set tile for the rest
      for tag = 2, 10 do
	 awful.tag.add(tostring(tag), {
			  layout =  awful.layout.layouts[1],
			  layouts = awful.layout.layouts,
			  screen = s,
	 })
      end

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = widgets.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                             awful.button({ }, 1, function () awful.layout.inc( 1) end),
                             awful.button({ }, 3, function () awful.layout.inc(-1) end),
                             awful.button({ }, 4, function () awful.layout.inc( 1) end),
                             awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    s.mytaglist = widgets.taglist(s)

    s.mytasklist = widgets.tasklist(s)

    if s == screen.primary then
       set_wallpaper()
       s.mywibox = awful.wibar({
             position = "bottom",
             screen = s,
             height = s.geometry.height * 0.019
       })

       local left_widgets = {}

       hostname = utils.hostname()

       if hostname == "intus" then
          left_widgets = {
             spacing = beautiful.widget_margin,
             layout = wibox.layout.fixed.horizontal,
             widgets.battery,
             widgets.volume,
             widgets.memory,
             widgets.cpu.temp,
             widgets.cpu.usage,
             widgets.date,
	     s.mylayoutbox,
	  }
       else
          left_widgets = {
             spacing = 10,
             layout = wibox.layout.fixed.horizontal,
             widgets.mpd,
             widgets.volume,
             widgets.memory,
             widgets.gpu.temp,
             widgets.cpu.temp,
             widgets.cpu.usage,
             widgets.date,
	     s.mylayoutbox,
	  }
       end

       s.mywibox:setup {
	  {
	     layout = wibox.layout.fixed.horizontal,
	     s.mytaglist,
	     s.mypromptbox,
	  },
          {
             {
                widget = s.mytasklist,
             },
             right = beautiful.widget_margin,
             left = beautiful.widget_margin,
             widget  = wibox.container.margin,
          },
          left_widgets,
	  layout = wibox.layout.align.horizontal,
       }
    end
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local update_volume_status = function()
   myvolume.volume = wpctl.get_volume().volume
end

-- {{{ Key bindings

-- Modal

globalkeys = gears.table.join(

   awful.key({}, "XF86AudioRaiseVolume",
      function()
	 wpctl.inc(5)
	 update_volume_status()
      end
   ),

   awful.key({}, "XF86AudioLowerVolume",
      function()
	 utils.wpctl.dec(5)
	 update_volume_status()
      end
   ),

   awful.key({}, "XF86AudioMute",
      function()
	 utils.wpctl.toggle_mute(5)
	 update_volume_status()
      end
   ),
   awful.key({}, "XF86MonBrightnessDown",
      function()
	 awful.spawn("light -U 10")
      end
   ),

   awful.key({}, "XF86MonBrightnessUp",
      function()
	 awful.spawn("light -A 10")
      end
   ),

   awful.key({}, "XF86Launch1",
      function()
	 awful.menu.client_list()
      end
   ),

   awful.key({}, "Print",
      function()
	 awful.spawn("shot full")
      end,
      {description = "screen shot", group = "hotkeys"}
   ),

   awful.key({"Shift"}, "Print",
      function()
	 awful.spawn("shot sel")
      end,
      {description = "screen shot", group = "hotkeys"}
   ),

   awful.key({ modkey }, "s",
      function()
	 awful.spawn("firefox")
      end,
      {description="open browser", group="hotkeys"}
   ),

   awful.key({ modkey, "Shift"}, "s",
      function()
         tabbed.create()
      end,
      {description="Create tabbed container", group="hotkeys"}
   ),

   awful.key({ modkey }, "e",
      function()
	 awful.spawn("emacsclient -c")
      end
   ),

   awful.key({ modkey, "Shift"}, "t",
      function()
	 awful.spawn("telegram-desktop")
      end,
      {description = "toggle keep on top", group = "client"}
   ),

   awful.key({ modkey }, "o",
      function()
	 utils.scratch.toggle(terminal.." -n scratch", {instance = "scratch"}, false)
      end,
      {description="open terminal scratchpad", group="awesome"}
   ),

   awful.key({ modkey }, "i",
      function()
	 utils.scratch.toggle("emacsclient -c --frame-parameters='(quote (name . \"music\") (width . 250) (height . 80))' -e '(open-emms-window)'", {instance = "music"}, false)
      end,
      {description="open terminal scratchpad", group="awesome"}
   ),

   awful.key({ modkey }, "u",
      function()
      utils.scratch.toggle("umpv", {instance = "umpv"}, false)
	end,
      {description="open umpv scratchpad", group="awesome"}
   ),

   awful.key({ modkey }, "Left",
      awful.tag.viewprev,
      {description = "view previous", group = "tag"}
   ),

   awful.key({ modkey }, "Right",
      awful.tag.viewnext,
      {description = "view next", group = "tag"}
   ),

   awful.key({ modkey }, "Escape",
      awful.tag.history.restore,
      {description = "go back", group = "tag"}
   ),

   awful.key({ modkey }, "j",
      function ()
         movements.focus(1)
      end,
      {description = "focus next by index", group = "client"}
   ),

    awful.key({ modkey }, "k",
        function ()
           movements.focus(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    awful.key({ modkey, "Shift" }, "j",
       function ()
          movements.swap(1)
       end
    ),

    awful.key({ modkey, "Shift" }, "k",
       function()
          movements.swap(-1)
       end,
       {description = "swap with previous client by index", group = "client"}
    ),

    awful.key({ modkey, "Control" }, "j",
       function()
	  awful.screen.focus_relative(1)
       end,
       {description = "focus the next screen", group = "screen"}
    ),

    awful.key({ modkey, "Control" }, "k",
       function()
	  awful.screen.focus_relative(-1)
       end,
       {description = "focus the previous screen", group = "screen"}
    ),

    awful.key({ modkey, "Control", "Shift" }, "j",
       function()
	  if client.focus then
	     client.focus:move_to_screen(1)
	  end
       end,
       {description = "focus the next screen", group = "screen"}
    ),

    awful.key({ modkey, "Control", "Shift"}, "k",
       function()
	  if client.focus then
	     client.focus:move_to_screen(-1)
	  end
       end,
       {description = "focus the previous screen", group = "screen"}
    ),

    awful.key({ modkey,  "Shift"  }, "u",
       awful.client.urgent.jumpto,
       {description = "jump to urgent client", group = "client"}
    ),
    awful.key({ modkey,           }, "Tab",
        function ()
           awful.client.focus.history.previous()
           if client.focus then
              client.focus:raise()
           end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
       {description = "open a terminal", group = "launcher"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
       {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
       {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l", function ()
          tabbed.iter(1)
    end,
       {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h", function ()
          tabbed.iter(-1)
    end,
       {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
       {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
       {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    -- awful.key({ modkey, "Shift" }, "r",
    --    function ()
    --       modal.grab{keymap=resize_map, name="Resize", stay_in_mode=true}
    --    end,
    --    {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
		 os.execute("sleep 1")
		 awful.spawn("xset dpms force suspend")
              end,
              {description = "Lock screen", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() awful.spawn("rofi -show drun") end,
              {description = "show the menubar", group = "launcher"})
)

local function swap_master(c)
   if c == awful.client.getmaster() then
      awful.client.swap.byidx(1)
      awful.client.focus.byidx(-1)
   else
      c:swap(awful.client.getmaster())
   end
end

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey }, "w",
       function(c)
	  c:kill()
       end,
       {description = "close", group = "client"}),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),

    awful.key({ modkey, "Shift" }, "Return", function (c)  swap_master(c) end,
              {description = "move to master", group = "client"}),

    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),

    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

awful.keygrabber {
    root_keybindings = {{{'Mod4', 'Shift'}, 'r', function() end }},
    keybindings = {
       {{}, 'h', function()
             awful.tag.incmwfact(-0.05)
       end },
       {{}, 'l', function()
             awful.tag.incmwfact(0.05)
       end },
    },
    stop_key = { 'Return', 'Escape' },
}

-- The following will **NOT** trigger the keygrabbing because it isn't exported
-- to the root (global) keys. Adding export_keybindings would solve that
-- root._execute_keybinding({'Mod4', 'Shift'}, 'i')
-- assert(#keybinding_works == 0)

-- But this will start the keygrabber because it is part of the root_keybindings
-- root._execute_keybinding({'Mod4'}, 'i')

-- Note that that keygrabber is running, all callbacks should work:
-- root.fake_input('key_press'  , 'a')
-- root.fake_input('key_release'  , 'a')

-- Calling the root keybindings now wont work because they are not part of
-- the keygrabber internal (own) keybindings, so keypressed_callback will
-- be called.
-- root._execute_keybinding({'Mod4'}, 'i')

-- Now the keygrabber own keybindings will work
-- root._execute_keybinding({'Mod4', 'Shift'}, 'i')
-- {{{ Rules

local center_float = function (client)
   awful.placement.centered(client,nil)
   client.ontop = true
end

awful.rules.rules = {
    -- All clients will match this rule.
   {
      rule = { },
      properties = {
         border_width = beautiful.border_width,
         border_color = beautiful.border_normal,
         focus = awful.client.focus.filter,
         raise = false,
         keys = clientkeys,
         buttons = clientbuttons,
         screen = awful.screen.preferred,
         placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen,
         size_hints_honor = false
      }
   },
   {
      rule_any = {
         instance = {
            "pinentry",
         },
         class = {
            "Pavucontrol",
         },
         name = {
            "Event Tester", -- xev.
         },
         role = {
            "AlarmWindow",
            "ConfigManager",
         }
      },
      properties = { floating = true },
      callback = center_float
   },
   {
      rule_any = {
         instance = {
            "scratch",
            "umpv",
            "music"}
      },
      properties = {
         floating = true,
         raise=true
       },
      callback = center_float
   },
   {
      rule_any =  {
         instance = {
            "scratch"
         }
      },
      properties = {
         width =  dpi(1500),
         height = dpi(750)
      }
   }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
local append_client = function(c, next)
   local cls = awful.client.tiled()
   for _, v in pairs(cls) do
      c:swap(v)
      if v == next then
	 break
      end
   end
end

local handle_new_clients = function(c)
   if not awesome.startup then
      local last = awful.client.focus.history.get(c.screen, 1)

      if last then
	 if #awful.client.tiled() > 2 then
	    append_client(c, last)
	 else
	    awful.client.setslave(c)
	 end
      end
   end

   if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
      awful.placement.no_offscreen(c)
   end
end

client.connect_signal("manage", handle_new_clients)

client.connect_signal("mouse::enter", function(c)
                         c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)
			 c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
			 c.border_color = beautiful.border_normal
end)

screen.connect_signal("arrange", function (s)
    local max = s.selected_tag.layout.name == "max"
    local floating = s.selected_tag.layout.name == "floating"
    local only_one = #s.tiled_clients == 1

    for _, c in pairs(s.clients) do
        if not floating and (max or only_one) and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)
