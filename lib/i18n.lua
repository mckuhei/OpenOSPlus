local fs = require("filesystem")
local i18n = {}
local cache = {}
local syslang = "en_US"

function i18n.get(name,langname)
    if cache[name] then
        return cache[name]
    end
    if not langname then
        langname=syslang
    end
    if not fs.exists("/usr/misc/lang/"..name.."/"..langname..".lang") then
        return nil
    end
    local lang={}
    for line in io.lines("/usr/misc/lang/"..name.."/"..langname..".lang") do
        if line:match(".+=.+") then
            local key,value=line:match("(.+)=(.+)")
            lang[key]=value:gsub("\\n","\n")
        end
    end
    cache[name]=lang
    return setmetatable({},{__index=lang})
end

function i18n.setLanguage(lang)
    if not fs.exists("/usr/misc/lang/System/"..lang..".lang") then
        return false
    end
    syslang=lang
    return true
end

function i18n.getLanguage()
    return syslang
end

return i18n