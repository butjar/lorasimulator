classdef DeviceSimulator
    properties
        Device
        Arrivals
    end

    methods
        function sim = DeviceSimulator(dev, arrivals)
            sim.Device = dev;
            sim.Arrivals = arrivals;
        end

        function packets = run(sim)
            packets = sim.Device.simulatePackets(sim.Arrivals);
        end
    end
end
