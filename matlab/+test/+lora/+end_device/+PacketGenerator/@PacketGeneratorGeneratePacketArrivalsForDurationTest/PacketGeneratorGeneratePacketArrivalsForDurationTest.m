classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
    fileparts(pwd))}) ...
    PacketGeneratorGeneratePacketArrivalsForDurationTest < matlab.mock.TestCase

    properties
        Result
        PacketDistLower
        PacketDistUpper
    end

    methods(TestMethodSetup)
        function initializeSut(testCase)
            import lora.end_device.PacketGenerator;
            import matlab.mock.actions.AssignOutputs;

            arrivalDistribution = makedist('Poisson', ...
                                           'lambda', 1000);
            testCase.PacketDistLower = 14;
            testCase.PacketDistUpper = 51;
            plDistribution = makedist('Uniform', ...
                                      'lower', testCase.PacketDistLower, ...
                                      'upper', testCase.PacketDistUpper);
            gen = PacketGenerator(arrivalDistribution, ...
                                  plDistribution);

            start = datetime(1970, 1, 1, 0, 0, 0);
            duration = seconds(100);
            rng(1,'twister');
            testCase.Result = ...
                gen.generatePacketArrivalsForDuration(start, ...
                                                      duration);
        end
    end

    methods(TestMethodTeardown)
    end

    methods (Test)
        function testResultIsTable(testCase)
            testCase.verifyInstanceOf(testCase.Result, 'table');
        end

        function testPacketArrivalInOrder(testCase)
            testCase.verifyTrue(issorted(testCase.Result.Arrival));
        end

        function testPacketLengthMin(testCase)
            testCase.verifyGreaterThanOrEqual(testCase.Result.PacketLength, ...
                                              testCase.PacketDistLower);
        end

        function testPacketLengthMax(testCase)
            testCase.verifyLessThanOrEqual(testCase.Result.PacketLength, ...
                                           testCase.PacketDistUpper);
        end
    end
end
