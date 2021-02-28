local shell = require("shell")
local args, ops = shell.parse(...)
local hostname = args[1]
local i18n = require("i18n").get("System")

if hostname then
  local file, reason = io.open("/etc/hostname", "w")
  if not file then
    io.stderr:write(string.format(i18n['failedopeningfileforwriting'] .. "\n", reason))
    return 1
  end
  file:write(hostname)
  file:close()
  ops.update = true
else
  local file = io.open("/etc/hostname")
  if file then
    hostname = file:read("*l")
    file:close()
  end
end

if ops.update then
  os.setenv("HOSTNAME_SEPARATOR", hostname and #hostname > 0 and ":" or "")
  os.setenv("HOSTNAME", hostname)
elseif hostname then
  print(hostname)
else
  io.stderr:write(i18n['hostname.notset'])
  return 1
end
