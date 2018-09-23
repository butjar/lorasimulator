classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
          fileparts(pwd))}) ...
          ModemSettingsTest < matlab.unittest.TestCase

     properties
          Modem
     end

     methods(TestMethodSetup)
          function initializeSut(testCase)
               import lora.ModemSettings;
               testCase.Modem = ModemSettings(125000.0, 9, 1, 0);
          end
     end

     methods(TestMethodTeardown)
     end

     methods (Test)
          function testSymbolDuration(testCase)
               modem = testCase.Modem;

               actual = modem.getSymbolDuration();
               expected = seconds(0.004096);
               testCase.verifyEqual(actual, expected);
          end
     end
end
