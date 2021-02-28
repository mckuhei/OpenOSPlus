local computer = require("computer")
local shell = require("shell")
local i18n = require("i18n").get("System")

local args = shell.parse(...)
if #args ~= 1 then
  io.write(i18n['userdel.usage'])
  return 1
end

if not computer.removeUser(args[1]) then
  io.stderr:write(i18n['userdel.nosuchuser'])
  return 1
end
