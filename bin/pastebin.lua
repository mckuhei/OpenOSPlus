--[[ This program allows downloading and uploading from and to pastebin.com.
     Authors: Sangar, Vexatos ]]
local component = require("component")
local fs = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local i18n = require("i18n").get("System")

if not component.isAvailable("internet") then
  io.stderr:write(i18n['requiresinternetcard'])
  return
end

local args, options = shell.parse(...)

-- This gets code from the website and stores it in the specified file.
local function get(pasteId, filename)
  local f, reason = io.open(filename, "w")
  if not f then
    io.stderr:write(string.format(i18n['failedopeningfileforwriting'], reason))
    return
  end

  io.write(i18n['pastebin.downloading'])
  local url = "https://pastebin.com/raw/" .. pasteId
  local result, response = pcall(internet.request, url)
  if result then
    io.write(i18n['success'] .. "\n")
    for chunk in response do
      if not options.k then
        string.gsub(chunk, "\r\n", "\n")
      end
      f:write(chunk)
    end

    f:close()
    io.write(string.format(i18n['pastebin.saveddatato'], filename))
  else
    io.write(i18n['failed'] .. "\n")
    f:close()
    fs.remove(filename)
    io.stderr:write(string.format(i18n['pastebin.httprequestfailed'], response))
  end
end

-- This makes a string safe for being used in a URL.
function encode(code)
  if code then
    code = string.gsub(code, "([^%w ])", function (c)
      return string.format("%%%02X", string.byte(c))
    end)
    code = string.gsub(code, " ", "+")
  end
  return code 
end

-- This stores the program in a temporary file, which it will
-- delete after the program was executed.
function run(pasteId, ...)
  local tmpFile = os.tmpname()
  get(pasteId, tmpFile)
  io.write(i18n['running'] .. "\n")

  local success, reason = shell.execute(tmpFile, nil, ...)
  if not success then
    io.stderr:write(reason)
  end
  fs.remove(tmpFile)
end

-- Uploads the specified file as a new paste to pastebin.com.
function put(path)
  local config = {}
  local configFile = loadfile("/etc/pastebin.conf", "t", config)
  if configFile then
    local result, reason = pcall(configFile)
    if not result then
      io.stderr:write(string.format(i18n['pastebin.failedloadingconfig'], reason))
    end
  end
  config.key = config.key or "fd92bd40a84c127eeb6804b146793c97"
  local file, reason = io.open(path, "r")

  if not file then
    io.stderr:write(string.format(i18n['failedopeningfileforreading'], reason))
    return
  end

  local data = file:read("*a")
  file:close()

  io.write("Uploading to pastebin.com... ")
  local result, response = pcall(internet.request,
        "https://pastebin.com/api/api_post.php", 
        "api_option=paste&" ..
        "api_dev_key=" .. config.key .. "&" ..
        "api_paste_format=lua&" ..
        "api_paste_expire_date=N&" ..
        "api_paste_name=" .. encode(fs.name(path)) .. "&" ..
        "api_paste_code=" .. encode(data))

  if result then
    local info = ""
    for chunk in response do
      info = info .. chunk
    end
    if string.match(info, "^Bad API request, ") then
      io.write(i18n['failed'] .. "\n")
      io.write(info)
    else
      io.write(i18n['success'] .. "\n")
      local pasteId = string.match(info, "[^/]+$")
      io.write(string.format(i18n['pastebin.uploadedas'], info))
      io.write(string.format(i18n['pastebin.rpgtda'] , pasteId))
    end
  else
    io.write(i18n['failed'] .. "\n")
    io.stderr:write(response)
  end
end

local command = args[1]
if command == "put" then
  if #args == 2 then
    put(shell.resolve(args[2]))
    return
  end
elseif command == "get" then
  if #args == 3 then
    local path = shell.resolve(args[3])
    if fs.exists(path) then
      if not options.f or not os.remove(path) then
        io.stderr:write(i18n['filealreadyexists'])
        return
      end
    end
    get(args[2], path)
    return
  end
elseif command == "run" then
  if #args >= 2 then
    run(args[2], table.unpack(args, 3))
    return
  end
end

-- If we come here there was some invalid input.
io.write(i18n['pastebin.usage'])