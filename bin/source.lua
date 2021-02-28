local shell = require("shell")
local process = require("process")
local i18n = require("i18n").get("System")

local args, options = shell.parse(...)

if #args ~= 1 then
  io.stderr:write(i18n['source.specifyasinglefiletosource']);
  return 1
end

local file, open_reason = io.open(args[1], "r")

if not file then
  if not options.q then
    io.stderr:write(string.format(i18n['source.couldnotsourcebecause'], args[1], open_reason));
  end
  return 1
end

local lines = file:lines()

while true do  
  local line = lines()
  if not line then
    break
  end
  local current_data = process.info().data
  
  local source_proc = process.load((assert(os.getenv("SHELL"), "no $SHELL set")))
  local source_data = process.list[source_proc].data
  source_data.aliases = current_data.aliases -- hacks to propogate sub shell env changes
  source_data.vars = current_data.vars
  process.internal.continue(source_proc, _ENV, line)
end

file:close()
