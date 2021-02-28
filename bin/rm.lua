local fs = require("filesystem")
local shell = require("shell")
local i18n = require("i18n").get("System")

local function usage() 
  print(i18n['rm.usage']..i18n['rm.commandline'])
end

local args, options = shell.parse(...)
if #args == 0 or options.help then
  usage()
  return 1
end

local bRec = options.r or options.R or options.recursive
local bForce = options.f or options.force
local bVerbose = options.v or options.verbose
local bEmptyDirs = options.d or options.dir
local promptLevel = (options.I and 3) or (options.i and 1) or 0

bVerbose = bVerbose and not bForce
promptLevel = bForce and 0 or promptLevel

local function perr(...)
  if not bForce then
    io.stderr:write(...)
  end
end

local function pout(...)
  if not bForce then
    io.stdout:write(...)
  end
end

local metas = {}

-- promptLevel 3 done before fs.exists
-- promptLevel 1 asks for each, displaying fs.exists on hit as it visits

local function _path(m) return shell.resolve(m.rel) end
local function _link(m) return fs.isLink(_path(m)) end
local function _exists(m) return _link(m) or fs.exists(_path(m)) end
local function _dir(m) return not _link(m) and fs.isDirectory(_path(m)) end
local function _readonly(m) return not _exists(m) or fs.get(_path(m)).isReadOnly() end
local function _empty(m) return _exists(m) and _dir(m) and (fs.list(_path(m))==nil) end

local function createMeta(origin, rel)
  local m = {origin=origin,rel=rel:gsub("/+$", "")}
  if _dir(m) then
    m.rel = m.rel .. '/'
  end
  return m
end

local function unlink(path)
  os.remove(path)
  return true
end

local function confirm()
  if bForce then
    return true
  end
  local r = io.read()
  return r == 'y' or r == 'yes' or r == i18n['yes']
end

local function remove_all(parent)
  if parent == nil or not _dir(parent) or _empty(parent) then
    return true
  end

  local all_ok = true
  if bRec and promptLevel == 1 then
    pout(string.format(i18n['rm.descendintodirectory'], parent.rel))
    if not confirm() then
      return false
    end

    for file in fs.list(_path(parent)) do
      local child = createMeta(parent.origin, parent.rel .. file)
      all_ok = remove(child) and all_ok
    end
  end

  return all_ok
end

local function remove(meta)
  if not remove_all(meta) then
    return false
  end

  if not _exists(meta) then
    perr(string.format(i18n['rm.cannotremove']..i18n['nosuchfile'].."\n", meta.rel))
    return false
  elseif _dir(meta) and not bRec and not (_empty(meta) and bEmptyDirs) then
    if not bEmptyDirs then
      perr(string.format(i18n['rm.cannotremove']..": "..i18n['rm.isadirectory'].."\n", meta.rel))
    else
      perr(string.format(i18n['rm.cannotremove']..": "..i18n['rm.directorynotempty'].."\n", meta.rel))
    end
    return false
  end

  local ok = true
  if promptLevel == 1 then
    if _dir(meta) then
      pout(string.format(i18n['rm.removedirectory'], meta.rel))
    elseif meta.link then
      pout(string.format(i18n['rm.removesymboliclink'], meta.rel))
    else -- file
      pout(string.format(i18n['rm.removeregularfile'], meta.rel))
    end

    ok = confirm()
  end

  if ok then
    if _readonly(meta) then
      perr(string.format(i18n['rm.cannotremove']..i18n['isreadonly'].."\n", meta.rel))
      return false
    elseif not unlink(_path(meta)) then
      perr(meta.rel .. i18n['rm.failedtoberemoved'])
      ok = false
    elseif bVerbose then
      pout(i18n['removed'].." '" .. meta.rel .. "'\n");
    end
  end

  return ok
end

for _,arg in ipairs(args) do
  metas[#metas+1] = createMeta(arg, arg)
end

if promptLevel == 3 and #metas > 3 then
  pout(string.format(i18n['rm.removearguments'], #metas))
  if not confirm() then
    return
  end
end

local ok = true
for _,meta in ipairs(metas) do
  local result = remove(meta)
  ok = ok and result
end

return bForce or ok
