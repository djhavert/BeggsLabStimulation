function writeCountPulseInCurrentWindow(fidData,countPulseInCurrentWindow)
    fwrite(fidData, [0 0 0 0 0 0 0], 'uint32');
    countPulseInCurrentWindow=countPulseInCurrentWindow+1;
    positionCurrent = ftell(fidData);
    position=positionCurrent-(countPulseInCurrentWindow)*7*4-8;
    fseek(fidData, position, 'bof');
    fwrite(fidData,uint32(countPulseInCurrentWindow), 'uint32');
    fseek(fidData,0 , 'eof');
end