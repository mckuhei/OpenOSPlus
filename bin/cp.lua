local shell = require("shell")
local transfer = require("tools/transfer")

local args, options = shell.parse(...)
options.h = options.h or options.help
if #args < 2 or options.h then
  io.write(require("i18n").get("System")['cp.usage'])
  return not not options.h
end

-- clean options for copy (as opposed to move)
options = 
{
  cmd = "cp",
  i = options.i,
  f = options.f,
  n = options.n,
  r = options.r,
  u = options.u,
  P = options.P,
  v = options.v,
  x = options.x,
  skip = {options.skip},
}

return transfer.batch(args, options)
