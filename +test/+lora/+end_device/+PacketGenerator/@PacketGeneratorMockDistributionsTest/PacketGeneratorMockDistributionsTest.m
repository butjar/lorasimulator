classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
          fileparts(pwd))}) ...
          PacketGeneratorMockDistributionsTest < matlab.mock.TestCase

    properties
        Generator
        ArrivalDistBehavior
        PlDistBehavior
    end

    methods(TestMethodSetup)
        function initializeSut(testCase)
            import lora.end_device.PacketGenerator;
            import matlab.mock.actions.AssignOutputs;

            [arrivalDistMock, arrivalDistBehavior] = ...
                testCase.createMock(?prob.PoissonDistribution);
            when(withExactInputs(arrivalDistBehavior.random), ...
                then(AssignOutputs(10000)));
            testCase.ArrivalDistBehavior = arrivalDistBehavior;

            [plDistMock, plDistBehavior] = ...
                testCase.createMock(?prob.UniformDistribution);
            when(withExactInputs(plDistBehavior.random), ...
                then(AssignOutputs(5)));
            testCase.PlDistBehavior = plDistBehavior;

            testCase.Generator = PacketGenerator(arrivalDistMock, plDistMock);
        end
    end

    methods(TestMethodTeardown)
    end

    methods (Test)
        function testGeneratePacketArrivalsForDurationPackets(testCase)
            start = datetime(1970, 1, 1, 0, 0, 0);
            duration = seconds(60);

            actual = ...
                testCase.Generator.generatePacketArrivalsForDuration(...
                    start, duration);
            % [10s; 20s; 30s; 40s; 50s; 60s]
            secs = (1:6)'.*seconds(10);
            % [start + 10s; start + 20s; ...]
            Arrival = arrayfun(@(x) start + x, secs);
            dateformat = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
            Arrival.Format = dateformat;

            PacketLength = ones(6, 1).*5;
            rowNames = cellstr(Arrival);
            expected = table(Arrival, PacketLength, 'RowNames', rowNames);

            testCase.verifyEqual(actual, expected);
        end

        function testGeneratePacketArrivalTime(testCase)
            time = datetime(1970, 1, 1, 0, 0, 0);
            [actual, ~] = testCase.Generator.generatePacketArrival(time);
            expected = time + seconds(10);

            testCase.verifyEqual(actual, expected);
        end

        function testGeneratePacketArrivalPl(testCase)
            time = datetime(1970, 1, 1, 0, 0, 0);
            [~, actual] = testCase.Generator.generatePacketArrival(time);
            expected = 5;

            testCase.verifyEqual(actual, expected);
        end

        function testGeneratePacketArrivalArrivalDistRandomCalled(testCase)
            import matlab.mock.constraints.WasCalled;
            time = datetime(1970, 1, 1, 0, 0, 0);
            testCase.Generator.generatePacketArrival(time);

            testCase.verifyThat(...
                withExactInputs(testCase.ArrivalDistBehavior.random), ...
                WasCalled('WithCount', 1));
        end

        function testGeneratePacketArrivalPlDistRandomCalled(testCase)
            import matlab.mock.constraints.WasCalled;
            time = datetime(1970, 1, 1, 0, 0, 0);
            testCase.Generator.generatePacketArrival(time);

            testCase.verifyThat(...
                withExactInputs(testCase.PlDistBehavior.random), ...
                WasCalled('WithCount', 1));
        end

        function testGeneratePacketArrivalsForDurationArrivalDistCalled(...
            testCase)
            import matlab.mock.constraints.WasCalled;
            start = datetime(1970, 1, 1, 0, 0, 0);
            duration = seconds(60);
            testCase.Generator...
                .generatePacketArrivalsForDuration(start, duration);

            testCase.verifyThat(...
                withExactInputs(testCase.ArrivalDistBehavior.random), ...
                WasCalled('WithCount', 7));
        end

        function testGeneratePacketArrivalsForDurationPlDistCalled(...
            testCase)
            import matlab.mock.constraints.WasCalled;
            start = datetime(1970, 1, 1, 0, 0, 0);
            duration = seconds(60);
            testCase.Generator...
                .generatePacketArrivalsForDuration(start, duration);

            testCase.verifyThat(...
                withExactInputs(testCase.PlDistBehavior.random), ...
                WasCalled('WithCount', 7));
        end
    end
end
