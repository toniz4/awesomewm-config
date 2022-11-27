local parse = function(cmd)
   local fd = io.popen(cmd)
   local output = fd:read("*all")
   fd:close()

   local status = {}
   status.volume = string.match(output, "%[(%d+)%%%]")
   status.muted = string.find(output, "[off]", 1, true) ~= nil
   return status
end

local toggle_mute = function(channel)
   local cmd = string.format("amixer set %s toggle", channel)

   return parse(cmd)
end

local set = function(channel, val)
   local cmd = string.format("amixer set %s %d%%", channel, val)
   return parse(cmd)
end

local inc = function(channel, val)
   local cmd = string.format("amixer set %s %d%%+", channel, val)
   return parse(cmd)
end

local dec = function(channel, val)
   local cmd = string.format("amixer set %s %d%%-", channel, val)
   return parse(cmd)
end

local get = function(channel)
   local cmd = string.format("amixer get %s", channel)

   return parse(cmd)
end

return {
   set=set,
   get=get,
   inc=inc,
   dec=dec,
   toggle_mute=toggle_mute,
}
