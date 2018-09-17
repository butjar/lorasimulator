import plot.CollisionRate.CollisionTable;

simulationDate = '06-May-2018 23:27:09';

inputDir = [pwd, '/results/simulations/', simulationDate, '/'];
cr = CollisionTable(inputDir);
outputDir = [pwd, '/results/collisions/', simulationDate, '/'];
mkdir(outputDir);
f = [outputDir, 'collisiontable.txt'];

writetable(cr.Table, f);