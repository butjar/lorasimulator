function t = arrivaltable(Arrival, PacketLength)
    dateformat = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
    Arrival.Format = dateformat;
    t = table(Arrival, PacketLength);
end
