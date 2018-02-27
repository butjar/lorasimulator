classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture(...
          fileparts(pwd))}) ...
          PacketGeneratorTest < matlab.mock.TestCase

     properties
          Generator
     end

     methods(TestMethodSetup)
          function initializeSut(testCase)
               import lora.PacketGenerator;
               import matlab.mock.actions.AssignOutputs;

               [stubDistribution, distributionBehavior] = ...
                    testCase.createMock(?prob.PoissonDistribution);
               when(withExactInputs(distributionBehavior.random), ...
                    then(AssignOutputs(0.25),...
                         then(AssignOutputs(0.75),...
                              then(AssignOutputs(0.5)))));

               airtimeTable = { 1, seconds(0.023808); ...
                                5, seconds(0.028928); ...
                                8, seconds(0.034048)};
               dc = 0.01;
               startDate = datetime(1970, 1, 1, 0, 0, 0);
               testCase.Generator = PacketGenerator(startDate, ...
                                                    stubDistribution, ...
                                                    airtimeTable, ...
                                                    dc);

          end
     end

     methods(TestMethodTeardown)
     end

     methods (Test)
          function testRandInInterval(testCase)
               import matlab.unittest.constraints.IsLessThanOrEqualTo;
               import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
               import matlab.unittest.constraints.EveryElementOf;

               nTestVars = 100;
               from = 0;
               to = 10;
               results = zeros(1, nTestVars);

               for i=1:100
                    results(i) = testCase.Generator.randInInterval(from, to);
               end

               testCase.verifyThat(EveryElementOf(results), ...
                    IsGreaterThanOrEqualTo(0));
               testCase.verifyThat(EveryElementOf(results), ...
                    IsLessThanOrEqualTo(10));
          end

          function testRandInIntervalWithDices(testCase)
               import matlab.unittest.constraints.IsEqualTo;
               import matlab.unittest.constraints.AbsoluteTolerance;

               rng(1);
               %https://en.wikipedia.org/wiki/Coupon_collector%27s_problem
               n = 6;
               diceRolls = 0;
               for k=1:n
                    diceRolls = diceRolls + (n / k);
               end

               % pretty good chance of having all numbers drawn
               diceRolls = floor(diceRolls) * 10;
               results = zeros(1, diceRolls);
               for i=1:diceRolls
                    results(i) = ...
                         int16(testCase.Generator.randInInterval(1, 6));
               end

               % test mean value
               expectedMean = 3.5;
               actualMean = mean(results);
               testCase.verifyThat(actualMean, IsEqualTo(expectedMean, ...
                   'Within', AbsoluteTolerance(0.1)));

               % test all values included
               actualResultsUniqueSorted = sort(unique(results));
               expectedResultsUniqueSorted = [1, 2, 3, 4, 5, 6];
               testCase.verifyEqual(actualResultsUniqueSorted, ...
                    expectedResultsUniqueSorted);
          end

          function testGeneratePacket(testCase)
               % seed that returns different packet length (1,3,2)
               rng(7, 'twister');
               nPackets = 3;
               actual = cell(nPackets, 4);
               startTime = datetime(1970, 1, 1, 0, 0, 0);
               for t = 0:(nPackets - 1)
                    currentTime = startTime + seconds(t);
                    [time, packetEndTime, packetLength, airtime] = ...
                         testCase.Generator.generatePacket(currentTime);
                    actual(t + 1, :) = {time, ...
                                        packetEndTime, ...
                                        packetLength, ...
                                        airtime;};
               end

               airtimeTable = testCase.Generator.AirtimeTable;
               expected = cell(3, 4);

               % time + arrival
               expectedArrivals = [startTime + seconds(0 + 0.25), ...
                                   startTime + seconds(1 + 0.75), ...
                                   startTime + seconds(2 + 0.50)];

               expectedPacketLengths = {airtimeTable{1, 1}, ...
                                        airtimeTable{3, 1}, ...
                                        airtimeTable{2, 1}};

               expectedAirtimes = [airtimeTable{1, 2}, ...
                                   airtimeTable{3, 2}, ...
                                   airtimeTable{2, 2}];

               % expected end time for packets (arrival + airtime)
               expected(:, 1) = num2cell(expectedArrivals);
               expected(:, 2) = num2cell(expectedArrivals + expectedAirtimes);
               expected(:, 3) = expectedPacketLengths;
               expected(:, 4) = num2cell(expectedAirtimes);

               testCase.verifyEqual(actual, expected);
          end
     end
end
