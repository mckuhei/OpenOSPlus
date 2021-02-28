local fs = require("filesystem")
local shell = require("shell")
local i18n = require("i18n").get("System")

local args, ops = shell.parse(...)
if #args == 0 then
  table.insert(args, ".")
end

local arg = args[1]
local path = shell.resolve(arg)

if ops.help then
  io.write([[Usage: list [path]
  path:
    optional argument (defaults to ./)
  Displays a list of files in the given path with no added formatting
  Intended for low memory systems
]])
  return 0
end

local real, why = fs.realPath(path)
if real and not fs.exists(real) then
  why = i18n['nosuchfile']
end
if why then
  io.stderr:write(string.format(i18n['cannotaccess'] .. " '%s': %s", arg, tostring(why)))
  return 1
end

for item in fs.list(real) do
  io.write(item, '\n')
end
