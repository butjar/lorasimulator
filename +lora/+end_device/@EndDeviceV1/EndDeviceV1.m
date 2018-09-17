classdef EndDeviceV1 < lora.end_device.EndDevice
    properties
        DutyCycle
        NumberPreambleSymbols
        HeaderMode
    end

    methods
        function ed = EndDeviceV1(id, addr, modem, dc, nPreamble, h)
            ed = ed@lora.end_device.EndDevice(id, addr, modem);
            ed.DutyCycle = dc;
            ed.NumberPreambleSymbols = nPreamble;
            ed.HeaderMode = h;
        end

        function packetTable = simulatePackets(ed, arrivals)
            toffTable = ed.initializeToffTable(arrivals.PacketLength);

            tableHeight = height(arrivals);
            packetArrivals(tableHeight, 1) = datetime;
            packetEnds(tableHeight, 1) = datetime;
            packetLengths = zeros(tableHeight, 1); 
            airtimes(tableHeight, 1) = duration;
            minArrivalTime = arrivals.Arrival(1);

            for iArrival=1:tableHeight
                arrivalTime = max([minArrivalTime, ...
                    arrivals.Arrival(iArrival)]);
                pl = arrivals.PacketLength(iArrival);
                toffEntry = num2cell(toffTable{num2str(pl), ...
                    {'Toff', 'TimeOnAir'}});
                [toff, timeOnAir] = toffEntry{:};
                % ToDo: Use packetEnd instead of arrival time                  
                minArrivalTime = arrivalTime + toff;
                packetLengths(iArrival, 1) = pl;
                airtimes(iArrival, 1) = timeOnAir;
                packetArrivals(iArrival, 1) = arrivalTime;
                packetEnds(iArrival, 1) = arrivalTime + timeOnAir;
            end

            packetTable = lora.util.packettable(packetArrivals, packetEnds, ...
                packetLengths, airtimes);
        end

        function t = initializeToffTable(ed, plArray)
            import lora.AirtimeCalculator;

            ac = AirtimeCalculator();
            t = lora.util.airtimetable(ac, ed.Modem, plArray, ...
                ed.NumberPreambleSymbols, ed.HeaderMode);
            toffFun = @(x) ed.computeToff(x);
            t.Toff = arrayfun(toffFun, t.TimeOnAir);
            t.Properties.RowNames = cellstr(num2str(t.PacketLength));
        end

        function toff = computeToff(ed, timeOnAir)
           toff =  (timeOnAir / ed.DutyCycle) - timeOnAir;
        end
    end
end
