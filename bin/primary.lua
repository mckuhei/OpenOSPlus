local component = require("component")
local shell = require("shell")
local i18n=require("i18n").get("System")

local args = shell.parse(...)
if #args == 0 then
  io.write(i18n['primary.usage'])
  io.write(i18n['primary.help'])
  return 1
end

local componentType = args[1]

if #args > 1 then
  local address = args[2]
  if not component.get(address) then
    io.stderr:write(i18n['primary.nocomponentwiththisaddress'])
    return 1
  else
    component.setPrimary(componentType, address)
    os.sleep(0.1) -- allow signals to be processed
  end
end
if component.isAvailable(componentType) then
  io.write(component.getPrimary(componentType).address, "\n")
else
  io.stderr:write(i18n['primary.nocomponentwiththistype'])
  return 1
end
