local computer = require("computer")

io.write(require("i18n").get("System")['rebooting'])
computer.shutdown(true)