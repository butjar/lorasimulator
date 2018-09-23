classdef PacketGenerator
    properties
        ArrivalDistribution
        PacketLengthDistribution
     end

    methods
        % arrivalDist - milliseconds between packet
        function gen = PacketGenerator(arrivalDist, plDist)
            gen.ArrivalDistribution = arrivalDist;
            gen.PacketLengthDistribution = plDist;
        end

        function t = generatePacketArrivalsForDuration(gen, ...
                                start, duration)
            
            numEstimatedArrivals = ceil(duration / ...
                milliseconds(gen.ArrivalDistribution.lambda));
            tDiff = milliseconds(...
                gen.ArrivalDistribution.random([numEstimatedArrivals, 1]));
            tDiff = gen.computeArrivalsForDistribution(tDiff, duration);
            arrival(numel(tDiff), 1) = duration;
            for iArrival = 1:numel(tDiff)
                arrival(iArrival) = sum(tDiff(1:iArrival));
            end
            arrival = arrival + start;
            packetLength = round(...
                gen.PacketLengthDistribution.random([numel(arrival), 1]));
            t = lora.util.arrivaltable(arrival, packetLength);
            
%             packetCell = cell(100000, 2);
%             time = start;
%             iPacket = 0;
%             packet = {};
% 
%             while time <= (start + duration)
%                 if ~isempty(packet)
%                     packetCell(iPacket, :) = packet;
%                 end
%                 [time, pl] = gen.generatePacketArrival(time);
%                 packet = {time, pl};
%                 iPacket = iPacket + 1;
%             end
% 
%             packetCell = packetCell(1:(iPacket - 1), :);
%             arrivals = lora.util.arrivaltable([packetCell{:, 1}]', ...
%                 [packetCell{:, 2}]');
        end

        function [time, pl] = generatePacketArrival(gen, time)
            time = time + milliseconds(gen.ArrivalDistribution.random());
            pl = round(gen.PacketLengthDistribution.random());
        end
        
        function arrivals = computeArrivalsForDistribution(gen, arrivals, duration)
            arrivalsTotalTime = sum(arrivals);
            if (arrivalsTotalTime > duration && ...
                    arrivalsTotalTime - arrivals(end) <= arrivalsTotalTime)
                    arrivals = arrivals(1:end-1);
            elseif (arrivalsTotalTime > duration)
                arrivals = gen.computeArrivalsForDistribution(...
                    arrivals(1:end-1), duration);
            elseif (arrivalsTotalTime < duration)
                newArrival = milliseconds(gen.ArrivalDistribution.random());
                arrivals = gen.computeArrivalsForDistribution(...
                    [arrivals; newArrival], duration);
            end
        end
    end
end
