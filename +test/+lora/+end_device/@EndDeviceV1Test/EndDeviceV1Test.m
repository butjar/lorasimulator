classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
          fileparts(pwd))}) ...
          EndDeviceV1Test < matlab.mock.TestCase

    properties
        Device
        DutyCycle
    end

    methods(TestMethodSetup)
        function initializeSut(testCase)
            import lora.end_device.EndDeviceV1;
            import lora.ModemSettings;

            id = dec2hex(1);
            addr = dec2hex(1);
            modem = ModemSettings(125000.0, 7, 1, 0);
            testCase.DutyCycle = 0.01;
            
            nPreamble = 6;
            h = 0;

            testCase.Device = EndDeviceV1(id, addr, modem, ...
                testCase.DutyCycle, nPreamble, h);
        end
    end

    methods(TestMethodTeardown)
    end

    methods (Test)

        function initializeToffTableTest(testCase)
            plArray = [13; 16; 20];
            actual = testCase.Device.initializeToffTable(plArray);
            PacketLength = [13; 16; 20];
            TimeOnAir = [0.044288; 0.049408; 0.054528] * seconds(1);
            Toff = [4.384512; 4.891392; 5.398272] * seconds(1);
            expected = table(PacketLength, TimeOnAir, Toff, ...
                'RowNames', {'13'; '16'; '20'});

            testCase.verifyEqual(actual, expected);
        end

        function computeToffTest(testCase)
            timeOnAir = seconds(1);
            actual = testCase.Device.computeToff(timeOnAir);
            expected = seconds(99);

            testCase.verifyEqual(actual, expected);
        end
    end
end
