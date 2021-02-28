-- load complex, if we can (might be low on memory)

local ok, why = pcall(function(...)
  return loadfile("/lib/core/full_ls.lua", "bt", _G)(...)
end, ...)

if not ok then
  if type(why) == "table" then
    if why.code == 0 then
      return
    end
    why = why.reason
  end
  io.stderr:write(string.format(require("i18n").get("System")['ls.list'], tostring(why)))
  return 1
end

return why