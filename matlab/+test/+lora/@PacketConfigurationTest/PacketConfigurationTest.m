classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
          fileparts(pwd))}) ...
          PacketConfigurationTest < matlab.unittest.TestCase

     properties
          Packet
     end

     methods(TestMethodSetup)
          function initializeSut(testCase)
               import lora.PacketConfiguration;

               testCase.Packet = PacketConfiguration(13, 8, 0);
          end
     end

     methods (Test)
          function testGetPreambleSymbolsTotal(testCase)
               packet = testCase.Packet;

               actual = packet.getPreambleSymbolsTotal();
               expected = 12.25;
               testCase.verifyEqual(actual, expected);
          end
     end
end
