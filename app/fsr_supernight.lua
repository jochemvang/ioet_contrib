require "cord"

cord.new(function()
	while true do
		storm.n.adcife_init()
		val = storm.n.adcife_sample_an0(2)
		print(val)
		cord.await(storm.os.invokeLater, 100*storm.os.MILLISECOND)
	end
end)

sh = require "stormsh"
sh.start()
cord.enter_loop()
