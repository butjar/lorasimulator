import lora.ModemSettings;
import lora.end_device.EndDeviceV1;
import simulator.DeviceSimulator;
import lora.end_device.PacketGenerator;

duration = seconds(3 * 3600);
startDate = datetime('now');

bw = 125000.0;
sf = 7; 
cr = 5;
de = 0;
modem = ModemSettings(bw, sf, cr, de);

lambda = 7138;
packetDistLower = 14;
packetDistUpper = 51;
arrivalDist = makedist('Poisson', ...
                       'lambda', lambda);
packetDist = makedist('Uniform', ...
                      'lower', packetDistLower, ...
                      'upper', packetDistUpper);

dc = 0.01;
nPreamble = 6;
h = 0;
numDevices = 140;
devAddr = 1;
dir = [pwd, '/results/simulations/', datestr(startDate)];
mkdir(dir);

tic
parfor i = 1:numDevices
    devId = i;
    packets = simulateDevice(devId, arrivalDist, packetDist, ...
        devAddr, modem, dc, nPreamble, h, startDate, duration)
    f = ([dir, '/dev', num2str(devId), '.txt']);
    writetable(packets, f);
end
toc

function packets = simulateDevice(devId, arrivalDist, packetDist, ...
    devAddr, modem, dc, nPreamble, h, startDate, duration)
    generator = lora.end_device.PacketGenerator(arrivalDist, packetDist);
    device = lora.end_device.EndDeviceV1(devId, devAddr, modem, dc, ...
        nPreamble, h);
    arrivals = generator.generatePacketArrivalsForDuration(startDate, ...
        duration);
    sim = simulator.DeviceSimulator(device, arrivals);
    packets = sim.run();
end

