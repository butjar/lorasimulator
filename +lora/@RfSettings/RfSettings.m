classdef RfSettings
     properties
          CenterFrequency
          TransmitPower
          HardwareImplementation
     end

     methods
          function rf = RfSettings(cfreq, ptx, rfi)
               rf.CenterFrequency = cfreq;
               rf.TransmitPower = ptx;
               rf.HardwareImplementation = rfi;
          end
     end
end
