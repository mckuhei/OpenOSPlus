local args, options = require("shell").parse(...)
local i18n = require("i18n").get("System")
if options.help then
  io.write(i18n['echo.usage'])
  return
end
if options.e then
  for index,arg in ipairs(args) do
    -- use lua load here to interpret escape sequences such as \27
    -- instead of writing my own language to interpret them myself
    -- note that in a real terminal, \e is used for \27
    args[index] = assert(load("return \"" .. arg:gsub('"', [[\"]]) .. "\""))()
  end
end
io.write(table.concat(args," "))
if not options.n then
  io.write("\n")
end
