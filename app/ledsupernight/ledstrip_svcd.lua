
require "cord"
require "svcd"

--fsrs = {}

storm.io.set_mode(storm.io.OUTPUT, storm.io.D2)
storm.io.set_mode(storm.io.OUTPUT, storm.io.D3)

strip = storm.n.led_init(50, 0x10000, 0x1000)

MOTDs = {"Default message!!" }

SVCD.init("ledsupernight", function()
    print "starting"
    SVCD.add_service(0x3009)
    -- LED set(position, r, g, b)
    SVCD.add_attribute(0x3009, 0x400a, function(pay, srcip, srcport)
        local ps = storm.array.fromstr(pay)
        local position = ps:get(1)
        local red = ps:get(2)
	local green = ps:get(3)
	local blue = ps:get(4)
        --print ("got a request to light led ", position, " color r = ", red, ", g = ", green, ", b = ", blue)

        storm.n.led_set(strip, position, red, green, blue)
    end)

    -- LED show()
    SVCD.add_attribute(0x3009, 0x400b, function(pay, srcip, srcport)
        print ("got a request to show leds ")
        storm.n.led_show(strip)
    end)

    -- LED clear()
    SVCD.add_attribute(0x3009, 0x400c, function(pay, srcip, srcport)
        print ("got a request to clear leds ")
	for i=1,49 do
		storm.n.led_set(strip, i, 0, 0, 0)
	end
        storm.n.led_show(strip)
    end)

    -- LED clear(position)
    SVCD.add_attribute(0x3009, 0x400d, function(pay, srcip, srcport)
        local ps = storm.array.fromstr(pay)
        local position = ps:get(1)
        print ("got a request to clear led ", position)

        storm.n.led_set(strip, position, 0, 0, 0)
    end)

    cord.new(function()
        while true do
            local msg = "This is supernight" --MOTDs[math.random(1,#MOTDs)]
            local arr = storm.array.create(#msg+1,storm.array.UINT8)
            arr:set_pstring(0, msg)
            SVCD.notify(0x3009, 0x400a, arr:as_str())
            cord.await(storm.os.invokeLater, 3*storm.os.SECOND)
        end
    end)
end)

--[[cord.new(function()
    cord.await(SVCD.init, "fsrserver")
    SVCD.advert_received = function(pay, srcip, srcport)
        local adv = storm.mp.unpack(pay)
        for k,v in pairs(adv) do
            --These are the services
            if k == 0x300a then
                --Characteristic
                for kk,vv in pairs(v) do
                    if vv == 0x400e and k == 0x300a then
                        -- This is FSR service
                        if fsrs[srcip] == nil then
                            print ("Discovered FSR: ", srcip)
                                SVCD.subscribe(srcip,0x300a, 0x400e, function()
                                    print("Message Receiver: ", msg)
                                end)
                        end
                        fsrs[srcip] = storm.os.now(storm.os.SHIFT_16)
                    end
                end
            end
        end
    end
end)]]--

cord.enter_loop()
