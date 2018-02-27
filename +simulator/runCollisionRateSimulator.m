import lora.ModemSettings;
import simulator.CollisionRateSimulator;

devices = 40;
dur = seconds(3600);
startDate = datetime('now');

bw = 125000.0;
sf = 7; 
cr = 5;
de = 0;
modem = ModemSettings(bw, sf, cr, de);

plArray = 14:51;
nPreamble = 6;
h = 0;

dc = 0.01;


simulator = CollisionRateSimulator(devices, ...
                                   startDate, ...
                                   dur, ...
                                   dc, ...
                                   modem, ...
                                   plArray, ...
                                   nPreamble, ...
                                   h);

airtimes = [simulator.AirtimeTable{:, 2}];
meanAirtime = mean(airtimes);
meanPackets = dur * dc / meanAirtime;
lambda = seconds(dur / meanPackets);
dist = makedist('Poisson', 'lambda', lambda);

tic
packets = simulator.simulatePackets(dist);
toc