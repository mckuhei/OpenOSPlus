local fs = require("filesystem")
local shell = require("shell")
local i18n = require("i18n").get("System")

local args = shell.parse(...)
if #args == 0 then
  io.write(i18n['man.usage'])
  return 1
end

local topic = args[1]
for path in string.gmatch(os.getenv("MANPATH"), "[^:]+") do
  path = shell.resolve(fs.concat(path, topic), "man")
  if path and fs.exists(path) and not fs.isDirectory(path) then
    os.execute(os.getenv("PAGER") .. " " .. path)
    os.exit()
  end
end
io.stderr:write(string.format(i18n['man.nomanualentryfor'], topic))
return 1
