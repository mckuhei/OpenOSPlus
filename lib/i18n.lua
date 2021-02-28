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
    local lang={}
    if fs.exists("/usr/misc/lang/"..name.."/en_US.lang") and langname~="en_US" then
        setmetatable(lang,{__index=i18n.get(name,"en_US")})
    end
    if not fs.exists("/usr/misc/lang/"..name.."/"..langname..".lang") then
        return lang
    end
    for line in io.lines("/usr/misc/lang/"..name.."/"..langname..".lang") do
        if line:match(".+=.+") then
            local key,value=line:match("(.+)=(.+)")
            lang[key]=value:gsub("\\n","\n")
        end
    end
    cache[name]=lang
    return setmetatable({},{__index=lang})
end

function i18n.clearCache()
    cache={}
end

function i18n.setLanguage(lang)
    if not fs.exists("/usr/misc/lang/System/"..lang..".lang") then
        return false
    end
    syslang=lang
    i18n.clearCache()
    return true
end

function i18n.getLanguage()
    return syslang
end

return i18n