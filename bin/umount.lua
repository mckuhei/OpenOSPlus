local fs = require("filesystem")
local shell = require("shell")
local i18n = require("i18n").get("System")

local args, options = shell.parse(...)

if #args < 1 then
  io.write(i18n['umount.usage'])
  return 1
end

local proxy, reason
if options.a then
  proxy, reason = fs.proxy(args[1])
  if proxy then
    proxy = proxy.address
  end
else
  local path = shell.resolve(args[1])
  proxy, reason = fs.get(path)
  if proxy then
    proxy = reason -- = path
    if proxy ~= path then
      io.stderr:write(i18n['umount.notamountpoint'])
      return 1
    end
  end
end
if not proxy then
  io.stderr:write(tostring(reason)..'\n')
  return 1
end

if not fs.umount(proxy) then
  io.stderr:write(i18n['umount.nothingtoumounthere'])
  return 1
end
