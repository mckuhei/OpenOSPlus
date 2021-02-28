local component = require("component")
local fs = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local text = require("text")
local i18n = require("i18n").get("System")

if not component.isAvailable("internet") then
  io.stderr:write(i18n['requiresinternetcard'])
  return
end

local args, options = shell.parse(...)
options.q = options.q or options.Q

if #args < 1 then
  io.write(i18n['wget.usage'])
  return
end

local url = text.trim(args[1])
local filename = args[2]
if not filename then
  filename = url
  local index = string.find(filename, "/[^/]*$")
  if index then
    filename = string.sub(filename, index + 1)
  end
  index = string.find(filename, "?", 1, true)
  if index then
    filename = string.sub(filename, 1, index - 1)
  end
end
filename = text.trim(filename)
if filename == "" then
  if not options.Q then
    io.stderr:write(i18n['wget.cnifpso'])
  end
  return nil, i18n['wget.missingtargetfilename'] -- for programs using wget as a function
end
filename = shell.resolve(filename)

local preexisted
if fs.exists(filename) then
  preexisted = true
  if not options.f then
    if not options.Q then
      io.stderr:write(i18n['filealreadyexists'])
    end
    return nil, i18n['filealreadyexists'] -- for programs using wget as a function
  end
end

local f, reason = io.open(filename, "a")
if not f then
  if not options.Q then
    io.stderr:write(string.format(i18n['failedopeningfileforwriting'], reason))
  end
  return nil, string.format(i18n['failedopeningfileforwriting'], reason) -- for programs using wget as a function
end
f:close()
f = nil

if not options.q then
  io.write(i18n['downloading'])
end
local result, response = pcall(internet.request, url, nil, {["user-agent"]="Wget/OpenComputers OpenOSplus/Opencomputers (mcku_hei@qq.com; thezhou2008@qq.com)"})
if result then
  local result, reason = pcall(function()
    for chunk in response do
      if not f then
        f, reason = io.open(filename, "wb")
        assert(f, string.format(i18n['failedopeningfileforwriting'], tostring(reason)))
      end
      f:write(chunk)
    end
  end)
  if not result then
    if not options.q then
      io.stderr:write(i18n['failed'] .. "\n")
    end
    if f then
      f:close()
      if not preexisted then
        fs.remove(filename)
      end
    end
    if not options.Q then
      io.stderr:write(string.format(i18n['httprequestfailed'], reason))
    end
    return nil, reason -- for programs using wget as a function
  end
  if not options.q then
    io.write(i18n['success'] .. "\n")
  end
  
  if f then
    f:close()
  end

  if not options.q then
    io.write(string.format(i18n['saveddatato'], filename))
  end
else
  if not options.q then
    io.write(i18n['failed'] .. "\n")
  end
  if not options.Q then
    io.stderr:write(string.format(i18n['httprequestfailed'], response))
  end
  return nil, response -- for programs using wget as a function
end
return true -- for programs using wget as a function
