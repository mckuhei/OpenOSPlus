local shell = require("shell")
local i18n = require("i18n").get("System")

local args = shell.parse(...)
if #args == 0 then
  io.write(i18n['which.usage'])
  return 255
end

for i = 1, #args do
  local result, reason = shell.resolve(args[i], "lua")
  
  if not result then
    result = shell.getAlias(args[i])
    if result then
      result = args[i] .. i18n['which.aliasedto'] .. result
    end
  end

  if result then
    print(result)
  else
    io.stderr:write(args[i] .. ": " .. reason .. "\n")
    return 1
  end
end
