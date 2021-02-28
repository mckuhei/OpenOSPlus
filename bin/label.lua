local shell = require("shell")
local devfs = require("devfs")
local comp = require("component")
local i18n = require("i18n").get("System")

local args, options = shell.parse(...)
if #args < 1 then
  io.write(i18n['label.usage'])
  return 1
end

local filter = args[1]
local label = args[2]

local proxy, reason

if options.a then
  for addr in comp.list() do
    if addr:sub(1, filter:len()) == filter then
      proxy, reason = comp.proxy(addr)
      break
    end
    local tmp_proxy = comp.proxy(addr)
    local tmp_label = devfs.getDeviceLabel(tmp_proxy)
    if tmp_label == filter then
      proxy = tmp_proxy
      break
    end
  end
else
  proxy, reason = devfs.getDevice(args[1])
end

if not proxy then
  io.stderr:write(reason..'\n')
  return 1
end

if #args < 2 then
  local label = devfs.getDeviceLabel(proxy)
  if label then
    print(label)
  else
    io.stderr:write(i18n['label.nolabel'])
    return 1
  end
else
  devfs.setDeviceLabel(proxy, args[2])
end
