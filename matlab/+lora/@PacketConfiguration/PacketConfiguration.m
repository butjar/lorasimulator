classdef PacketConfiguration

     properties
          NumberPayloadBytes
          NumberPreambleSymbols
          HeaderMode
     end

     methods
          function config = PacketConfiguration(pl, nPreamble, h)
               config.NumberPayloadBytes = pl;
               config.NumberPreambleSymbols = nPreamble;
               config.HeaderMode = h;
          end

          function nPreambleTotal = getPreambleSymbolsTotal(config)
               nPreamble = config.NumberPreambleSymbols;

               nPreambleTotal = nPreamble + 4.25;
          end
     end
end
