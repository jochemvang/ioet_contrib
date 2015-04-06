
require "cord"
require "svcd"

storm.io.set_mode(storm.io.OUTPUT, storm.io.D2)
storm.io.set_mode(storm.io.OUTPUT, storm.io.D3)

strip = storm.n.led_init(50, 0x10000, 0x1000)

MOTDs = {"Default message!!" }

SVCD.init("ledsupernight", function()
    print "starting"
    SVCD.add_service(0x3101)
    -- LED set(position, r, g, b)
    SVCD.add_attribute(0x3101, 0x4105, function(pay, srcip, srcport)
        local ps = storm.array.fromstr(pay)
        local position = ps:get(1)
        local red = ps:get(2)
	local green = ps:get(3)
	local blue = ps:get(4)
        print ("got a request to light led ", position, " color r = ", red, ", g = ", green, ", b = ", blue)

        storm.n.led_set(strip, position, red, green, blue)
    end)

    -- LED show()
    SVCD.add_attribute(0x3101, 0x4106, function(pay, srcip, srcport)
        print ("got a request to show leds ")
        storm.n.led_show(strip)
    end)

    -- LED clear()
    SVCD.add_attribute(0x3101, 0x4107, function(pay, srcip, srcport)
        print ("got a request to clear leds ")
	for i=1,49 do
		storm.n.led_set(strip, i, 0, 0, 0)
	end
        storm.n.led_show(strip)
    end)

    -- LED clear(position)
    SVCD.add_attribute(0x3101, 0x4108, function(pay, srcip, srcport)
        local ps = storm.array.fromstr(pay)
        local position = ps:get(1)
        print ("got a request to clear led ", position)

        storm.n.led_set(strip, position, 0, 0, 0)
    end)

--FSR
    SVCD.add_service(0x3102)
    
    SVCD.add_attribute(0x3102, 0x4205, function(pay, srcip, srcport)
    end)

    cord.new(function()
        while true do
            print ("sending FSR notifications")
	    storm.n.adcife_init()
	    local val = storm.n.adcife_sample_an0(2)
	    local val_str = tostring(val)
	    print ("Value = ", val)
            local arr = storm.array.create(#val_str+1, storm.array.UINT8)
            arr:set_pstring(0, val_str)
            SVCD.notify(0x3102, 0x4205, arr:as_str())
            cord.await(storm.os.invokeLater, 1*storm.os.SECOND)
        end
    end)
end)

cord.enter_loop()
