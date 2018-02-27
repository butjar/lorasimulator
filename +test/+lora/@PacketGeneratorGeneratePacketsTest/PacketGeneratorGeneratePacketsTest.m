classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
          fileparts(pwd))}) ...
          PacketGeneratorGeneratePacketsTest < matlab.mock.TestCase

     properties
          Generator
          Packets
          DutyCycle
          StartDate
          Duration
     end

     methods(TestMethodSetup)
          function initializeSut(testCase)
               import lora.PacketGenerator;
               import matlab.mock.actions.AssignOutputs;

               [stubDistribution, distributionBehavior] = ...
                    testCase.createMock(?prob.PoissonDistribution);
               when(withExactInputs(distributionBehavior.random), ...
                    then(AssignOutputs(0.0), ...
                         then(AssignOutputs(36.0))));

               airtimeTable = {242, seconds(0.371968)};
               testCase.DutyCycle = 0.01;

               testCase.StartDate = datetime(1970, 1, 1, 0, 0, 0);
               testCase.Generator = PacketGenerator(testCase.StartDate, ...
                                                    stubDistribution, ...
                                                    airtimeTable, ...
                                                    testCase.DutyCycle);
               rng(1,'twister');
               testCase.Duration = seconds(3700);
               testCase.Packets = ...
                    testCase.Generator.generatePacketsForDuration(testCase.Duration);
          end
     end

     methods(TestMethodTeardown)
     end

     methods (Test)
          function packetArrivesAfterPrevious(testCase)
               import matlab.unittest.constraints.IsEqualTo;

               [nRows, ~] = size(testCase.Packets);
               arrivalArray = reshape(testCase.Packets(:, 1), 1, nRows);
               packetsArrivedBeforeSucceding = zeros(1, numel(arrivalArray));
               arrayPointer = 0;
               for i=2:numel(arrivalArray)
                    if arrivalArray{i} < arrivalArray{i - 1}
                         arrayPointer = arrayPointer + 1;
                         packetsArrivedBeforeSucceding(arrayPointer) = i;
                    end
               end


               diag = ['The packets at following index have arrived ' ...
                       'before its succeeding packet: ' ...
                       num2str(packetsArrivedBeforeSucceding)];

               testCase.verifyThat(arrayPointer, IsEqualTo(0), diag);
          end

          function dutyCycleNotExceededDuringFirstHour(testCase)
               import matlab.unittest.constraints.AbsoluteTolerance;

               startNextHour = testCase.StartDate + hours(1);
               packetArrivals = [testCase.Packets{:,1}];
               lastPacketIndex = find(packetArrivals < startNextHour, 1, 'last');
               airtimesFirstHour = [testCase.Packets{1:lastPacketIndex, 4}];
               actual = sum(airtimesFirstHour);
               expected = seconds(3600) * testCase.DutyCycle;
               testCase.verifyLessThanOrEqual(actual, expected);
          end
     end
end
