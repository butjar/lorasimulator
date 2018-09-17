function t = packettable(Arrival, End, PacketLength, TimeOnAir)
    dateformat = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSSSSS';
    Arrival.Format = dateformat;
    durationformat = 'hh:mm:ss.SSSSSSSSS';
    TimeOnAir.Format = durationformat;
    End.Format = dateformat;
    rowNames = cellstr(Arrival);
    t = table(Arrival, End, PacketLength, TimeOnAir, 'RowNames', rowNames);
end
