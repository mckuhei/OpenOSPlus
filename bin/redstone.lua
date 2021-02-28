local colors = require("colors")
local component = require("component")
local shell = require("shell")
local sides = require("sides")
local i18n = require("i18n").get("System")

if not component.isAvailable("redstone") then
  io.stderr:write(i18n['requiresredstone'])
  return 1
end
local rs = component.redstone

local args, options = shell.parse(...)
if #args == 0 and not options.w and not options.f then
  io.write(i18n['redstone.usage'])
  if rs.setBundledOutput then
    io.write(i18n['redstone.usage2'])
  end
  if rs.setWirelessOutput then
    io.write(i18n['redstone.usage3'])
  end
  return
end

if options.w then
  if not rs.setWirelessOutput then
    io.stderr:write(i18n['redstone.wirelessredstonenotavailable'])
    return 1
  end
  if #args > 0 then
    local value = args[1]
    if tonumber(value) then
      value = tonumber(value) > 0
    else
      value = ({["true"]=true,["on"]=true,["yes"]=true})[value] ~= nil
    end
    rs.setWirelessOutput(value)
  end
  io.write("in: " .. tostring(rs.getWirelessInput()) .. "\n")
  io.write("out: " .. tostring(rs.getWirelessOutput()) .. "\n")
elseif options.f then
  if not rs.setWirelessOutput then
    io.stderr:write(i18n['redstone.wirelessredstonenotavailable'])
    return 1
  end
  if #args > 0 then
    local value = args[1]
    if not tonumber(value) then
      io.stderr:write(i18n['redstone.invalidfreq'])
      return 1
    end
    rs.setWirelessFrequency(tonumber(value))
  end
  io.write(string.format(i18n['redstone.freq'], tostring(rs.getWirelessFrequency())))
else
  local side = sides[args[1]]
  if not side then
    io.stderr:write(i18n['redstone.invalidside'])
    return 1
  end
  if type(side) == "string" then
    side = sides[side]
  end

  if options.b then
    if not rs.setBundledOutput then
      io.stderr:write(i18n['bundledredstonenotavailable'])
      return 1
    end
    local color = colors[args[2]]
    if not color then
      io.stderr:write(i18n['redstone.invalidcolor'])
      return 1
    end
    if type(color) == "string" then
      color = colors[color]
    end
    if #args > 2 then
      local value = args[3]
      if tonumber(value) then
        value = tonumber(value)
      else
        value = ({["true"]=true,["on"]=true,["yes"]=true})[value] and 255 or 0
      end
      rs.setBundledOutput(side, color, value)
    end
    io.write(string.format(i18n['redstone.in'], rs.getBundledInput(side, color)))
    io.write(string.format(i18n['redstone.out'], rs.getBundledOutput(side, color)))
  else
    if #args > 1 then
      local value = args[2]
      if tonumber(value) then
        value = tonumber(value)
      else
        value = ({["true"]=true,["on"]=true,["yes"]=true})[value] and 15 or 0
      end
      rs.setOutput(side, value)
    end
    io.write(string.format(i18n['redstone.in'], rs.getInput(side)))
    io.write(string.format(i18n['redstone.out'], rs.getOutput(side)))
  end
end
