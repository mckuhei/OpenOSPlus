local shell = require("shell")
local transfer = require("tools/transfer")

local args, options = shell.parse(...)
options.h = options.h or options.help
if #args < 2 or options.h then
  io.write(require("i18n").get("System")['mv.usage'])
  return not not options.h
end

-- clean options for move (as opposed to copy)
options = 
{
  cmd = "mv",
  f = options.f,
  i = options.i,
  v = options.v,
  n = options.n, -- no clobber
  skip = {options.skip},
  P = true, -- move operations always preserve
  r = true, -- move is allowed to move entire dirs
  x = true, -- cannot move mount points
}

return transfer.batch(args, options)
