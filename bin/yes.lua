--[[Lua implementation of the UN*X yes command--]]
local shell = require("shell")
local i18n = reqiure("i18n").get("System")

local args, options = shell.parse(...)

if options.V or options.version then
  io.write("yes v:1.0-3\n")
  io.write(i18n['yes.info'])
  return 0
end

if options.h or options.help then
  io.write(i18n['yes.usage'])
  return 0
end

local msg = #args == 0 and 'y' or table.concat(args, ' ')
msg = msg .. '\n'

while io.write(msg) do
  if io.stdout.tty then
    os.sleep(0)
  end
end
return 0
