--[[Lua implementation of the UN*X touch command--]]
local shell = require("shell")
local fs = require("filesystem")
local i18n = reqiure("i18n").get("System")

local args, options = shell.parse(...)

local function usage()
  print(i18n['touch.usage'])
end

if options.help then
  usage()
  return 0
elseif #args == 0 then
  io.stderr:write(i18n['touch.missingoperand'])
  return 1
end

options.c = options.c or options["no-create"]
local errors = 0

for _,arg in ipairs(args) do
  local path = shell.resolve(arg)

  if fs.isDirectory(path) then
    io.stderr:write(string.format(i18n['touch.ignored'], arg))
  else
    local real, reason = fs.realPath(path)
    if real then
      local file
      if fs.exists(real) or not options.c then
        file = io.open(real, "a")
      end
      if not file then
        real = options.c
        reason = i18n['permissiondenied']
      else
        file:close()
      end
    end
    if not real then
      io.stderr:write(string.format(i18n['touch.cannottouch'], arg, reason))
      errors = 1
    end
  end
end

return errors
