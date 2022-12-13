local wpctl = {}

wpctl.sink = "@DEFAULT_AUDIO_SINK@"

local query = function(cmd)
   local fd = io.popen("wpctl " .. cmd .. " " .. wpctl.sink)
   local output = fd:read("*all")
   fd:close()

   local status = {}
   status.volume = tonumber(string.match(output, "[%d.]+")) * 100
   status.muted = string.find(output, "[MUTED]", 1, true) ~= nil
   return status
end

local execute = function(cmd, args)
   os.execute("wpctl " .. cmd .. " " .. wpctl.sink .. " " .. args)
end

wpctl.get_volume = function()
   status = query("get-volume")

   return status
end

wpctl.inc = function(val)
   status = query("get-volume")

   if (status.volume + val) <= 100 then
      execute("set-volume", val .. "%+")
   end
end

wpctl.dec = function(val)
   execute("set-volume", val .. "%-")
end

wpctl.toggle_mute = function()
   execute("set-mute", "toggle")
end

return wpctl
