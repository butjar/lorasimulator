classdef (Abstract) EndDevice
    properties
        DevEui
        DevAddr
        Modem
    end

    methods
        function ed = EndDevice(id, addr, modem)
            ed.DevEui = id;
            ed.DevAddr = addr;
            ed.Modem = modem;
        end
    end

    methods (Abstract)
        packetTable = simulatePackets(ed, arrivals)
    end
end
