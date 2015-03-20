require "cord" -- scheduler / fiber library

storm.io.set_mode(storm.io.OUTPUT, storm.io.D2)
storm.io.set_mode(storm.io.OUTPUT, storm.io.D3)

strip = storm.n.led_init(5, 0x10000, 0x1000)
storm.n.led_set(strip, 0, 31, 20, 0)
storm.n.led_set(strip, 2, 31, 10, 0)
storm.n.led_show(strip)

sh = require "stormsh"
sh.start()
cord.enter_loop() -- start event/sleep loop
