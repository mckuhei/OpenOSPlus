local computer = require("computer")
local total = computer.totalMemory()
local max = 0
for _=1,40 do
  max = math.max(max, computer.freeMemory())
  os.sleep(0) -- invokes gc
end
io.write(string.format(require("i18n").get("System")['free.freememory'], total, total - max, max))
