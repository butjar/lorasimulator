classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
          fileparts(pwd))}) ...
          AirtimeCalculatorTest < matlab.unittest.TestCase

     properties
          Calculator
          Modem
          Packet
     end

     methods(TestMethodSetup)
          function initializeSut(testCase)
               import lora.AirtimeCalculator;
               import lora.ModemSettings;
               import lora.PacketConfiguration;

               testCase.Calculator = AirtimeCalculator();
               bw = 125000.0;
               sf = 9;
               cr = 1;
               de = 0;
               testCase.Modem = ModemSettings(bw, sf, cr, de);

               pl = 13;
               nPreamble = 8;
               h = 0;
               testCase.Packet = PacketConfiguration(pl, nPreamble, h);
          end
     end

     methods (Test)
          function testPayloadSymbolCalculation(testCase)
               ac = testCase.Calculator;
               modem = testCase.Modem;
               packet = testCase.Packet;

               actual = ac.calculatePayloadSymbols(modem, packet);
               expected = 28;
               testCase.verifyEqual(actual, expected);
          end

          function testPreambleDurationCalculation(testCase)
               ac = testCase.Calculator;
               modem = testCase.Modem;
               packet = testCase.Packet;

               actual = ac.calculatePreambleDuration(modem, packet);
               expected = seconds(0.050176);
               testCase.verifyEqual(actual, expected);
          end

          function testPayloadDurationCalculation(testCase)
               ac = testCase.Calculator;
               modem = testCase.Modem;
               packet = testCase.Packet;

               actual = ac.calculatePayloadDuration(modem, packet);
               expected = seconds(0.114688);
               testCase.verifyEqual(actual, expected);
          end

          function testTimeOnAirCalculation(testCase)
               ac = testCase.Calculator;
               modem = testCase.Modem;
               packet = testCase.Packet;

               actual = ac.calculateTimeOnAir(modem, packet);
               expected = seconds(0.164864);
               testCase.verifyEqual(actual, expected);
          end
     end
end
