local fs = require("filesystem")
local shell = require("shell")
local i18n = require("i18n").get("System")

local args = shell.parse(...)
if #args == 0 then
  io.write(i18n['mkdir.usage'])
  return 1
end

local ec = 0
for i = 1, #args do
  local path = shell.resolve(args[i])
  local result, reason = fs.makeDirectory(path)
  if not result then
    if not reason then
      if fs.exists(path) then
        reason = i18n['']
      else
        reason = i18n['mkdir.unknown']
      end
    end
    io.stderr:write(string.format(i18n['mkdir.cannotcreate'], tostring(args[i], reason)))
    ec = 1
  end
end

return ec
