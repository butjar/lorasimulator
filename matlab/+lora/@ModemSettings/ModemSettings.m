classdef ModemSettings
     properties
          Bandwidth
          SpreadingFactor
          CodingRate
          DatarateOptimizationEnabled
     end

     methods
          function modem = ModemSettings(bw, sf, cr, de)
               modem.Bandwidth = bw;
               modem.SpreadingFactor = sf;
               modem.CodingRate = cr;
               modem.DatarateOptimizationEnabled = de;
          end

          function tSym = getSymbolDuration(modem)
               sf = modem.SpreadingFactor;
               bw = modem.Bandwidth;

               tSym = seconds(2.0 ^ sf / bw);
          end
     end
end
