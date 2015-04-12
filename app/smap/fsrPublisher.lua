-- TODO: Make library

--FSR = require "fsr" --fsr library
require "cord"
--fsr = FSR:new()

shellip = "2001:470:66:3f9::2" --IP of middleware service

storm.io.set_mode(storm.io.INPUT, storm.io.A0)
sendsock = storm.net.udpsocket(1337, function() end)

cord.new(function ()
    --fsr:init()
    storm.n.adcife_init()
    while true do
        cord.await(storm.os.invokeLater, 1000 * storm.os.MILLISECOND)
        --local data = fsr:get()
        local data = storm.n.adcife_sample_an0(0)
        local t = {data}
        storm.net.sendto(sendsock, storm.mp.pack(t), shellip, 2198)
    end
end)

cord.enter_loop()

