local computer = require("computer")
local i18n = require("i18n").get("System")
local options

do
  local basic, reason = loadfile("/lib/core/install_basics.lua", "bt", _G)
  if not basic then
    io.stderr:write(string.format(i18n['install.failedtoloadinstall'], tostring(reason)))
    return 1
  end
  options = basic(...)
end

if not options then
  return
end

if computer.freeMemory() < 50000 then
  print(i18n['lowmemory'])
  for i = 1, 20 do
    os.sleep(0)
  end
end

local transfer = require("tools/transfer")
for _, inst in ipairs(options.cp_args) do
  local ec = transfer.batch(table.unpack(inst))
  if ec ~= nil and ec ~= 0 then
    return ec
  end
end

print(i18n['install.complete'])

if options.setlabel then
  pcall(options.target.dev.setLabel, options.label)
end

if options.setboot then
  local address = options.target.dev.address
  if computer.setBootAddress(address) then
    print(string.format(i18n['install.bootaddresssetto'], address))
  end
end

if options.reboot then
  io.write(i18n['install.reboot?'])
  local yesorno = io.read()
  if ((yesorno or "n") .. "y"):match("^%s*[Yy]" or yesorno == i18n['yes']) then
    print(i18n['install.rebootingnow'])
    computer.shutdown(true)
  end
end

print(i18n['install.returningtoshell'])
