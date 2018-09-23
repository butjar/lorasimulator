fName = 'collisiontable.txt';
date = '06-May-2018 23:27:09';
d = [pwd, '/results/collisions'];
f = [d, '/', date, '/', fName];

dateformat = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
dateTextscanFormat = ['%{', dateformat, '}D'];
format = ['%f', dateTextscanFormat, ...
    ' ', dateTextscanFormat, ' %f', ' %T', ' %f', ' %q'];
t = readtable(f, 'Format', format);
devices = sort(unique(t.Device));

NumDevices = zeros(numel(devices), 1);
PacketsTotal = zeros(numel(devices), 1);
CollisionsCount = zeros(numel(devices), 1);
CollisionRate = zeros(numel(devices), 1);

tic
parfor numDevices = 1:numel(devices)
    NumDevices(numDevices) = numDevices;
    rows = t.Device <= numDevices;
    packets = t(rows, :);
    PacketsTotal(numDevices) = height(packets);
    ids = packets.Id;
    Collisions = packets.Collisions;
    for iCollisions = 1:numel(Collisions)
        collisions = str2num(Collisions{iCollisions});
        members = ismember(collisions, ids);
        Collisions{iCollisions} = strip(...
            sprintf('%.0f ', collisions(members)));
    end
    packets.Collisions = Collisions;
    CollisionsCount(numDevices) = numel(find(~cellfun('isempty', Collisions)));
    CollisionRate(numDevices) = CollisionsCount(numDevices) / PacketsTotal(numDevices);
end
toc

collisionRateTable = table(NumDevices, PacketsTotal, CollisionsCount, CollisionRate);
plot(collisionRateTable.NumDevices, collisionRateTable.CollisionRate);