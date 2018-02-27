import matlab.unittest.Test
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

s = what([pwd '/test']);

suite = Test.empty(1, 0);

for i=1:numel(s.packages())
    package = ['test.' char(s.packages(i))];
    suite = [suite, TestSuite.fromPackage(package)];
end

result = run(suite);
