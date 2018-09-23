function t = airtimetable(ac, modem, plArray, nPreamble, h)
    import lora.PacketConfiguration;

    PacketLength = sort(unique(plArray));
    [n, m] = size(PacketLength);
    TimeOnAir(n, m) = seconds(0);
    packet = PacketConfiguration(0, nPreamble, h);

    for iPl = 1:numel(PacketLength)
        pl = PacketLength(iPl);
        packet.NumberPayloadBytes = pl;

        TimeOnAir(iPl) = ac.calculateTimeOnAir(modem, packet);
    end

    rowNames = cellstr(num2str(PacketLength));
    t = table(PacketLength, TimeOnAir, 'RowNames', rowNames);
end
