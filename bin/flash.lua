local component = require("component")
local shell = require("shell")
local fs = require("filesystem")
local i18n = require("i18n").get("System")

local args, options = shell.parse(...)

if #args < 1 and not options.l then
  io.write(i18n['flash.usage'])
  return
end

local function printRom()
  local eeprom = component.eeprom
  io.write(eeprom.get())
end

local function readRom()
  local eeprom = component.eeprom
  fileName = shell.resolve(args[1])
  if not options.q then
    if fs.exists(fileName) then
      io.write(string.format(i18n['flash.aysywto'], fileName))
      io.write(i18n['flash.typeytoconfirm'])
      repeat
        local response = io.read()
      until response and response:lower():sub(1, 1) == "y" or response == i18n['yes']
    end
    io.write(i18n['flash.readingeeprom'] .. eeprom.address .. ".\n" )
  end
  local bios = eeprom.get()
  local file = assert(io.open(fileName, "wb"))
  file:write(bios)
  file:close()
  if not options.q then
    io.write(i18n['flash.alldonethelabelis'] .. "'" .. eeprom.getLabel() .. "'.\n")
  end
end

local function writeRom()
  local file = assert(io.open(args[1], "rb"))
  local bios = file:read("*a")
  file:close()

  if not options.q then
    io.write(i18n['flash.iteywltf'])
    io.write(i18n['flash.whenreadytoflash'])
    repeat
      local response = io.read()
    until response and response:lower():sub(1, 1) == "y" or response == i18n['yes']
    io.write(i18n['flash.beginningtoflasheeprom'])
  end

  local eeprom = component.eeprom

  if not options.q then
    io.write(string.format(i18n['flash.flashingeeprom'], eeprom.address) .. " .\n")
    io.write(i18n['flash.pdnpdorycdto'])
  end

  eeprom.set(bios)

  local label = args[2]
  if not options.q and not label then
    io.write(i18n['flash.enlftelibtltlu'])
    label = io.read()
  end
  if label and #label > 0 then
    eeprom.setLabel(label)
    if not options.q then
      io.write(string.format(i18n['flash.setlabelto'], eeprom.getLabel()) .. "' .\n")
    end
  end

  if not options.q then
    io.write(i18n['flash.adycrtearitpon'])
  end
end

if options.l then
  printRom()
elseif options.r then
  readRom()
else
  writeRom()
end
