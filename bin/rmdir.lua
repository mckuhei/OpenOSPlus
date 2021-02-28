local shell = require("shell")
local fs =  require("filesystem")
local text = require("text")
local i18n = require("i18n").get("System")

local args, options = shell.parse(...)

local function usage()
  print(i18n['rmdir.usage'])
end

if options.help then
  usage()
  return 0
end

if #args == 0 then
  io.stderr:write(i18n['rmdir.missingoperand'])
  return 1
end

options.p = options.p or options.parents
options.v = options.v or options.verbose
options.q = options.q or options['ignore-fail-on-non-empty']

local ec = 0
local function ec_bump()
  ec = 1
  return 1
end

local function remove(path, ...)
  -- check to end recursion
  if path == nil then
    return true
  end

  if options.v then
    print(string.format(i18n['rmdir.removeingdirectory'], path))
  end

  local rpath = shell.resolve(path)
  if path == '.' then
    io.stderr:write(i18n['rmdir.invalid'])
    return ec_bump()
  elseif not fs.exists(rpath) then
    io.stderr:write(string.format(i18n['rmdir.pathdoesnotexist'], path))
    return ec_bump()
  elseif fs.isLink(rpath) or not fs.isDirectory(rpath) then
    io.stderr:write(string.format(i18n['rmdir.notadirectory'], path))
    return ec_bump()
  else
    local list, reason = fs.list(rpath)
        
    if not list then
      io.stderr:write(tostring(reason)..'\n')
      return ec_bump()
    else
      if list() then
        if not options.q then
          io.stderr:write(string.format(i18n['rmdir.directorynotempty'], path))
        end
        return ec_bump()
      else
        -- path exists and is empty?
        local ok, reason = fs.remove(rpath)
        if not ok then
          io.stderr:write(tostring(reason)..'\n')
          return ec_bump(), reason
        end
        return remove(...) -- the final return of all else
      end
    end
  end
end

for _,path in ipairs(args) do
  -- clean up the input
  path = path:gsub('/+', '/')

  local segments = {}
  if options.p and path:len() > 1 and path:find('/') then
    chain = text.split(path, {'/'}, true)
    local prefix = ''
    for _,e in ipairs(chain) do
      table.insert(segments, 1, prefix .. e)
      prefix = prefix .. e .. '/'
    end
  else
    segments = {path}
  end

  remove(table.unpack(segments))
end

return ec
