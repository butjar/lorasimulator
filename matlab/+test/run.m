import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

suite = TestSuite.fromPackage('test', 'IncludingSubpackages', true);

result = run(suite);