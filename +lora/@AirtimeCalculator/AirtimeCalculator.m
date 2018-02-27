% https://www.semtech.com/uploads/documents/LoraDesignGuide_STD.pdf
% https://docs.google.com/spreadsheets/d/1voGAtQAjC1qBmaVuP1ApNKs1ekgUjavHuVQIXyYSvNc/edit#gid=0

classdef AirtimeCalculator

     methods
          function ac = AirtimeCalculator()
          end

          function nPayloadSymbols = calculatePayloadSymbols(~, modem, packet)
               nPayloadBytes = packet.NumberPayloadBytes;
               sf = modem.SpreadingFactor;
               h = packet.HeaderMode;
               de = modem.DatarateOptimizationEnabled;
               cr = modem.CodingRate;

               nPayloadBits = 8.0 * nPayloadBytes - 4.0 * sf ...
                    + 28.0 + 16.0 - 20.0 * h;

               nPayloadSymbols = 8.0 + max( ...
                    [ceil(nPayloadBits / (4.0 * (sf - 2.0 * de))) ...
                    * (cr + 4.0), 0.0]);
          end

          function tPreamble = calculatePreambleDuration(~, modem, packet)
               nPreambleSymbols = packet.getPreambleSymbolsTotal();
               tSym = modem.getSymbolDuration();

               tPreamble = nPreambleSymbols * tSym;
          end

          function tPayload = calculatePayloadDuration(ac, modem, packet)
               nPayloadSymbols = ac.calculatePayloadSymbols(modem, packet);
               tSym = modem.getSymbolDuration();

               tPayload = nPayloadSymbols * tSym;
          end

          function timeOnAir = calculateTimeOnAir(ac, modem, packet)
               tPreamble = ac.calculatePreambleDuration(modem, packet);
               tPayload = ac.calculatePayloadDuration(modem, packet);

               timeOnAir = tPreamble + tPayload;
          end
     end
end
