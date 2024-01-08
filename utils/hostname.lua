
local function get_hostname()
   return io.popen("uname -n"):read()
end

return get_hostname
