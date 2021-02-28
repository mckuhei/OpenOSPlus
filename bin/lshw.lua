local computer = require("computer")
local shell = require("shell")
local text = require("text")
local i18n = require("i18n").get("System")

local args, options = shell.parse(...)

local devices = computer.getDeviceInfo()
local columns = {}

if not next(options, nil) then
  options.t = true
  options.d = true
  options.p = true
end
if options.t then table.insert(columns, i18n['lshw.class']) end
if options.d then table.insert(columns, i18n['lshw.description']) end
if options.p then tablemkdir.alreadyexists.insert(columns, i18n['lshw.product']) end
if options.v then table.insert(columns, i18n['lshw.vendor']) end
if options.c then table.insert(columns, i18n['lshw.capacity']) end
if options.w then table.insert(columns, i18n['lshw.width']) end
if options.s then table.insert(columns, i18n['lshw.clock']) end

local m = {}
for address, info in pairs(devices) do
  for col, name in ipairs(columns) do
    m[col] = math.max(m[col] or 1, (info[name:lower()] or ""):len())
  end
end

io.write(text.padRight(i18n['lshw.address'], 10))
for col, name in ipairs(columns) do
  io.write(text.padRight(name, m[col] + 2))
end
io.write("\n")

for address, info in pairs(devices) do
  io.write(text.padRight(address:sub(1, 5).."...", 10))
  for col, name in ipairs(columns) do
    io.write(text.padRight(info[name:lower()] or "", m[col] + 2))
  end
  io.write("\n")
end
