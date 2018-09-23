classdef CollisionTable
    properties
        Table
    end

    methods
        function ct = CollisionTable(d)
            t = readFiles(ct, d);
            tic
            ct.Table = ct.markCollisions(t);
            toc
        end

        function t = markCollisions(ct, t)
            tHeight = height(t);
            Collisions = strings(tHeight, 1); 
            parfor iPacket = 1:tHeight
                collidingPacketIds = ct.computeCollidingPacketIds(iPacket, t);
                collidingPacketIds = strip(...
                    sprintf('%.0f ', collidingPacketIds));
                Collisions{iPacket} = collidingPacketIds;
            end
            t = [t table(Collisions)];
        end
        
        function ids = computeCollidingPacketIds(ct, iPacket, t)
            packet = t(iPacket, :);
            collidingPackets = ct.fetchCollidingPackets(packet, ...
                t([1:(iPacket-1) (iPacket+1):end], :));
            ids = collidingPackets.Id;
        end

        function t = readFiles(~, d)
            dateformat = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
            dateTextscanFormat = strcat("%{", dateformat,"}D");
            ds = tabularTextDatastore(d, 'FileExtensions','.txt');
            ds.TextscanFormats = {dateTextscanFormat, ...
                dateTextscanFormat, "%f", "%T"};
            ds.ReadSize = 'file';
            t = table;
            while hasdata(ds)
                [nextT, info] = read(ds);
                tokens = regexp(info.Filename, '.*\/dev(\d*)\.txt', 'tokens');
                deviceId  = str2double(tokens{1}{:});
                Device(1:height(nextT), 1) = deviceId;
                nextT = [nextT table(Device)];
                clear Device;
                t = [t; nextT];
            end
            t = sortrows(t, {'Arrival', 'Device'}, {'ascend', 'ascend'});
            Id = (1:height(t)).';
            t = [table(Id) t];
        end
        
        function packets = fetchCollidingPackets(~, packet, t)
            % https://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
            rows = (t.End >= packet.Arrival & t.Arrival <= packet.End) ...
                | (packet.End >= t.Arrival & packet.Arrival <= t.End);
            packets = t(rows, :);
        end
    end
end