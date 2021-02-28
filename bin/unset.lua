local args = {...}

if #args < 1 then
  io.write(require("i18n").get("System")['unset.usage'])
else
  for _, k in ipairs(args) do
    os.setenv(k, nil)
  end
end
