local computer = require('computer')
local sh = require('sh')
local i18n = require("i18n").get("System")

local real_before, cpu_before = computer.uptime(), os.clock()
local cmd_result = 0
if ... then
  sh.execute(nil, ...) 
  cmd_result = sh.getLastExitCode()
end
local real_after, cpu_after = computer.uptime(), os.clock()

local real_diff = real_after - real_before
local cpu_diff = cpu_after - cpu_before

print(string.format(i18n['time.real'], math.floor(real_diff/60), real_diff%60))
print(string.format(i18n['time.cpu'], math.floor(cpu_diff/60), cpu_diff%60))

return cmd_result
