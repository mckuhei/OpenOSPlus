local shell = require("shell")
local fs = require("filesystem")
local i18n = require("i18n").get("System")
local args, ops = shell.parse(...)
local path = nil
local verbose = false

if ops.help then
  print(i18n["cd.usage"])
  return
end

if #args == 0 then
  local home = os.getenv("HOME")
  if not home then
    io.stderr:write(i18n['cat.home'])
    return 1
  end
  path = home
elseif args[1] == '-' then
  verbose = true
  local oldpwd = os.getenv("OLDPWD");
  if not oldpwd then
    io.stderr:write(i18n["cat.oldpwd"])
    return 1
  end
  path = oldpwd
else
  path = args[1]
end

local resolved = shell.resolve(path)
if not fs.exists(resolved) then
  io.stderr:write("cd: ",path,": "..i18n['nosuchfile']..'\n')
  return 1
end

path = resolved
local oldpwd = shell.getWorkingDirectory()
local result, reason = shell.setWorkingDirectory(path)
if not result then
  io.stderr:write("cd: ", path, ": ", reason)
  return 1
else
  os.setenv("OLDPWD", oldpwd)
end
if verbose then
  os.execute("pwd")
end
