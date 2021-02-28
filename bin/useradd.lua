local computer = require("computer")
local shell = require("shell")

local args = shell.parse(...)
if #args ~= 1 then
  io.write(require("i18n").get("System")['useradd.usage'])
  return 1
end

local result, reason = computer.addUser(args[1])
if not result then
  io.stderr:write(reason..'\n')
  return 1
end
