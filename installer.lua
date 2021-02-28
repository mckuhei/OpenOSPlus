local component = require("component")
local gpu = component.gpu
local resX, resY = gpu.getResolution()
local cdn="https://github.com/kebufu/OpenOSPlus/raw/master"

if not component.isAvailable("internet") then
	io.stderr:write("This installer require an internet card to run.\n")
	return
end
local stdout=io.stdout
stdout:write("Welcome to OpenOS+ installer.\n")
stdout:write("Do you want install now?[Y/N]")
if string.lower(io.read())~="y" then
	stdout:write("Install cancled.\n")
	return
end

stdout:write("Are you live in China?[y/N]")
if string.lower(io.read())=="y" then
	cdn="https://mirror.opencomputers.ml:1337/openosplus"
end

local fs      =require("filesystem")
local computer=require("computer")

local internet=component.internet

local function download(file,quit)
	local handle=internet.request(file,nil,{["User-Agent"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"})
	local chunk=''
	repeat
		data=handle.read(math.huge)
		computer.uptime()
		if data then
			chunk=chunk..data
		end
	until not data
	return chunk
end
stdout:write("getting files.cfg\n")
local needDownload={}
for key,value in pairs(load("return "..download(cdn.."/files.cfg"))()) do
    fs.makeDirectory(key)
    for _,file in ipairs(value) do
		table.insert(needDownload,key.."/"..file)
	end
end
for i=1,#needDownload do
	local path=needDownload[i]
    local url=cdn..path
	stdout:write(url.." -> "..path.."\27[K\n")
    resX_=resX-16
    a=math.floor((i/#needDownload)*resX_,1)
    gpu.set(1,resY,"Installing... ["..string.rep("█",a)..string.rep(" ",(resX_)-a).."]")
	f=fs.open(path,"w")
	f:write(download(i))
	f:close()
end
gpu.fill(1,resY,resX,1," ")