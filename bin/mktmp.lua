local fs = require("filesystem")
local shell = require("shell")
local sh = require("sh")
local i18n = require("i18n").get("System")

local touch = loadfile(shell.resolve("touch", "lua"))
local mkdir = loadfile(shell.resolve("mkdir", "lua"))

if not touch then
  local errorMessage = i18n['mktmp.missingtools']
  io.stderr:write(errorMessage .. '\n')
  return false, errorMessage
end

local args, ops = shell.parse(...)

local function pop(...)
  local result
  for _,key in ipairs({...}) do
    result = ops[key] or result
    ops[key] = nil
  end
  return result
end

local directory = pop('d')
local verbose = pop('v', 'verbose')
local quiet = pop('q', 'quiet')

if pop('help') or #args > 1 or next(ops) then
  print(i18n['mktmp.usage'])
  if next(ops) then
    io.stderr:write(string.format(i18n['mktmp.invalidoption'], next(ops)))
    return 1
  end
  return
end

if not verbose then
  if not quiet then
    if io.stdout.tty then
      verbose = true
    end
  end
end

local prefix = args[1] or os.getenv("TMPDIR") .. '/'
if not fs.exists(prefix) then
  io.stderr:write(
    string.format(
      i18n['mktmp.cctfodaidne'], 
      prefix))
  return 1
end

local tmp = os.tmpname()
local ok, reason = (directory and mkdir or touch)(tmp)

if sh.internal.command_passed(ok) then
  if verbose then
    print(tmp)
  end
  return tmp
end

return ok, reason
