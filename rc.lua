-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")

-- Theme
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local widgets = require("widgets")
local helpers = require("helpers")
local utils = require("utils")

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

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
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
-- }}}

-- {{{ Variable definitions

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

naughty.config.defaults.border_width = beautiful.notification_border_width

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

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

local myvolume = widgets.volume("Master")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                          awful.menu.client_list({ theme = { width = 250 } })
end))

function set_wallpaper(s)
   if beautiful.wallpaper then
      local wallpaper = beautiful.wallpaper


      if not gears.filesystem.file_readable(wallpaper) then
	 gears.wallpaper.set(wallpaper, s)
	 return
      end

      surf = gears.surface.load_uncached(wallpaper)

      local w, h = gears.surface.get_size(surf)

      -- If the image is small, tile it
      if w < 500 or h < 500 then
	 gears.wallpaper.tiled(surf, s)
      else
	 gears.wallpaper.maximized(surf, s, true)
      end
   end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

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

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
	filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons,

    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
	style = {
	   align = "center",
	},
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ height = 15, position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
       layout = wibox.layout.align.horizontal,
       { -- Left widgets
	  layout = wibox.layout.fixed.horizontal,
	  --mylauncher,
	  s.mytaglist,
	  s.mypromptbox,
       },
       s.mytasklist, -- Middle widget
       { -- Right widgets
	  spacing = 5,
	  layout = wibox.layout.fixed.horizontal,
	  widgets.temp,
	  widgets.battery,
	  myvolume,
	  widgets.time,
	  --wibox.widget.systray(),
	  --mytextclock,
	  s.mylayoutbox,
       },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

   awful.key({}, "XF86AudioRaiseVolume",
      function()
	 helpers.alsa.inc("Master", 5)
	 myvolume.volume = helpers.alsa.get("Master")["volume"]
      end
   ),

   awful.key({}, "XF86AudioLowerVolume",
      function()
	 helpers.alsa.dec("Master", 5)
	 myvolume.volume = helpers.alsa.get("Master")["volume"]
      end
   ),

   awful.key({}, "XF86AudioMute",
      function()
	 helpers.alsa.toggle_mute("Master")
	 myvolume.volume = helpers.alsa.get("Master")["volume"]
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
	 awful.spawn(os.getenv("BROWSER"))
      end,
      {description="open browser", group="hotkeys"}
   ),

   awful.key({ modkey }, "e",
      function()
	 awful.spawn("emacsclient -c")
      end
   ),

   awful.key({ modkey, "Shift"}, "t",
      function()
	 awful.spawn("kotatogram-desktop")
      end,
      {description = "toggle keep on top", group = "client"}
   ),

   awful.key({ modkey }, "o",
      function()
	 utils.scratch.toggle("xst -n scratch", {instance = "scratch"}, false)
      end,
      {description="open terminal scratchpad", group="awesome"}
   ),

   awful.key({ modkey }, "i",
      function()
	 utils.scratch.toggle("emacsclient -c --frame-parameters='(quote (name . \"music\") (width . 160) (height . 27))' -e '(emms-smart-browse)'", {instance = "music"}, false)
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
	 awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
   ),

    awful.key({ modkey }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j",
       function ()
	  awful.client.swap.byidx( 1)
       end
    ),

    awful.key({ modkey, "Shift" }, "k",
       function()
	  awful.client.swap.byidx(-1)
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

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
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

    awful.key({ modkey, "Shift" },            "r",     function () client_menu() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
		 awful.spawn("slock")
              end,
              {description = "Lock screen", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
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
    -- awful.key({ modkey,           }, "f",
    --     function (c)
    --         c.fullscreen = not c.fullscreen
    --         c:raise()
    --     end,
    --     {description = "toggle fullscreen", group = "client"}),

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

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = false,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          -- "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    { rule_any = { instance = { "scratch", "umpv", "music"} },
      properties = { floating = true, raise=true},
      callback = function (c)
         awful.placement.centered(c,nil)
	 c.ontop = true
      end
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
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
      last = awful.client.focus.history.get(c.screen, 1)
      
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

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", handle_new_clients)

-- Enable sloppy focus, so that focus follows mouse.
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
-- }}}
