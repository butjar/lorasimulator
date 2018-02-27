classdef CollisionRateSimulator
     properties
         Devices
         Duration
         AirtimeTable
         DutyCycle
         StartDate
     end

     methods
          function sim = CollisionRateSimulator(devices, ...,
                                                startDate, ...
                                                dur, ...
                                                dc, ...
                                                modem,...
                                                plArray, ...
                                                nPreamble, ...
                                                h)
               sim.Devices = devices;
               sim.StartDate = startDate;
               sim.Duration = dur;
               sim.DutyCycle = dc;
               sim.AirtimeTable = sim.calculateAirtimeTable(modem, ...
                                                            plArray, ...
                                                            nPreamble, ...
                                                            h);

          end

          function airtimeTable = calculateAirtimeTable(~, ...
                                                        modem, ...
                                                        plArray, ...
                                                        nPreamble, ...
                                                        h)
               import lora.PacketConfiguration;
               import lora.AirtimeCalculator;

               airtimeTable = cell(numel(plArray), 2);
               parfor i = 1:numel(plArray)
                   pl = plArray(i);
                   packet = PacketConfiguration(pl, nPreamble, h);
                   airtime = AirtimeCalculator().calculateTimeOnAir(modem, packet);
                   airtimeTable(i, :) = {pl, airtime};
               end
          end
          
          function packets = simulatePackets(sim, dist)
              import lora.PacketGenerator;

              packets = cell(1000000, 4, numel(sim.Devices));
              maxPackets = 0;
              for i = 1:sim.Devices
                  pg = PacketGenerator(sim.StartDate, ...
                                       dist, ...
                                       sim.AirtimeTable, ...
                                       sim.DutyCycle);
                  devPackets = pg.generatePacketsForDuration(sim.Duration);
                  [n, ~] = size(devPackets);
                  packets(1:n, :, i) = devPackets;   
                  if n > maxPackets
                    maxPackets = n;
                  end
              end
              
              packets(maxPackets+1:end, :, :) = [];
          end
     end
end
