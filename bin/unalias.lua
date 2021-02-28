local shell = require("shell")
local i18n = require("i18n").get("System")

local args = shell.parse(...)
if #args < 1 then
  io.write(i18n['unalias.usage'])
  return 2
end
local e = 0

for _,arg in ipairs(args) do
  local result = shell.getAlias(arg)
  if not result then
    io.stderr:write(string.format("unalias: %s: " .. i18n['notfound'] .. "\n", arg))
    e = 1
  else
    shell.setAlias(arg, nil)
  end
end
return e
