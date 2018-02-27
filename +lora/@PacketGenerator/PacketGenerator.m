classdef PacketGenerator
     properties
          StartDate
          Distribution
          AirtimeTable
          PacketLengths
          Airtimes
          DutyCycle
     end

     methods
          function gen = PacketGenerator(startDate, dist, airtimeTable, dc)
               gen.StartDate = startDate;
               gen.Distribution = dist;
               gen.AirtimeTable = airtimeTable;
               gen.PacketLengths = [airtimeTable{:, 1}];
               gen.Airtimes = [airtimeTable{:, 2}];
               gen.DutyCycle = dc;
          end

          function packets = generatePacketsForDuration(gen, duration)
               time = gen.StartDate;
               packets = cell(100000, 4);
               i = 1;
               airtimeInHour = seconds(0);
               maxAirtimeInHour = seconds(3600) * gen.DutyCycle;
               packet = {};

               while 1
                    [time, packetEndTime, packetLength, airtime] = ...
                        gen.generatePacket(time);

                    nextPacket = {time, ...
                                  packetEndTime, ...
                                  packetLength, ...
                                  airtime;};

                    airtimeInHour = gen.updateAirtimeInHour(airtimeInHour, ...
                                                            packet, ...
                                                            nextPacket);

                    % Duty cycle reached
                    if airtimeInHour >= maxAirtimeInHour
                         [time, packetEndTime, ~, ~] = ...
                              sendPacketNextHour(gen, nextPacket);
                         nextPacket(1:2) = {time, packetEndTime};
                    end

                    if packetEndTime > (gen.StartDate + duration)
                        break;
                    end

                    packet = nextPacket;
                    packets(i, :) = packet;
                    i = i + 1;
               end

               packets(i:end, :) = [];
          end

          function updatedAirtime = updateAirtimeInHour(gen, ...
                                                        airtimeInHour, ...
                                                        packet, ...
                                                        nextPacket)
               if ~isempty(packet)
                   arrival = packet{1};
                   nextArrival = nextPacket{1};
                   if gen.compareHour(arrival, nextArrival) ~= 0
                       airtimeInHour = 0;
                   end
               end
               nextAirtime = nextPacket{4};
               updatedAirtime = airtimeInHour + nextAirtime;
          end

          function val = compareHour(~, t1, t2)
               if t1.Year < t2.Year || t1.Day  < t2.Day  || t1.Hour < t2.Hour
                    val = -1;
               elseif t1.Year > t2.Year || t1.Day > t2.Day || t1.Hour > t2.Hour
                    val = 1;
               else
                    val = 0;
               end
          end

          function [time, packetEndTime, packetLength, airtime] = ...
               sendPacketNextHour(gen, packet)

               [time, ~, packetLength, airtime] = packet{:};
               time = datetime(time.Year, time.Month, time.Day, time.Hour, ...
                               0, 0) + hours(1);
               randomBackoff = seconds(gen.randInInterval(0.0, 2.0));
               time = time + randomBackoff;
               packetEndTime = time + airtime;
          end

          function [time, packetEndTime, packetLength, airtime] = ...
               generatePacket(gen, time)

               arrival = seconds(gen.Distribution.random());
               udIndex = int16(gen.randInInterval(1, ...
                                   numel(gen.PacketLengths)));
               packetLength = gen.PacketLengths(udIndex);
               indices = find(gen.PacketLengths == packetLength);
               index = indices(1);
               airtime = gen.Airtimes(index);
               time = time + arrival;
               packetEndTime = time + airtime;
          end

%          function dcReached = isDutyCycleReached(gen, time, packets)
%               maxAirtime = (floor(time.Hour / ho) + 1) * dcSeconds;
%               dcReached = aggregatedAirtime >= maxAirtime;
%          end

          % https://de.mathworks.com/help/matlab/math/floating-point-numbers-within-specific-range.html
          function num = randInInterval(~, from, to)
               num = (to - from).*rand() + from;
          end
     end
end
