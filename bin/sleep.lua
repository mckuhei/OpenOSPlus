local shell = require("shell")
local tty = require("tty")
local args, options = shell.parse(...)
local i18n = require("i18n").get("System")

if options.help then
  print(i18n['sleep.usage'])
end

local function help(bad_arg)
  print(string.format(i18n['sleep.invalidoption'], tostring(bad_arg)))
end

local function time_type_multiplier(time_type)
  if not time_type or #time_type == 0 or time_type == 's' then
    return 1
  elseif time_type == 'm' then
    return 60
  elseif time_type == 'h' then
    return 60 * 60
  elseif time_type == 'd' then
    return 60 * 60 * 24
  end

  -- weird error, my bad
  assert(false,string.format(i18n['sleep.bug'] ,tostring(time_type)))
end

options.help = nil
if next(options) then
  help(next(options))
  return 1
end

local total_time = 0

for _,v in ipairs(args) do
  local interval, time_type = v:match('^([%d%.]+)([smhd]?)$')
  interval = tonumber(interval)

  if not interval or interval < 0 then
    help(v)
    return 1
  end

  total_time = total_time + time_type_multiplier(time_type) * interval
end

local ins = io.stdin.stream
local pull = ins.pull
local start = 1
if not pull then
  pull = require("event").pull
  start = 2
end
pull(select(start, ins, total_time, "interrupted"))
