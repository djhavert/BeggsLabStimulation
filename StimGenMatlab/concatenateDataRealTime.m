function concatenateDataRealTime(saveLocationData,nameFileDataPart,nameFileDataAll)
fid=fopen([saveLocationData nameFileDataPart '.bin'],'r','l');

RealTime=fread(fid,'uint32')';

fclose(fid); 
fidData=fopen([saveLocationData nameFileDataAll '.bin'],'w+','l');
for i=1:100
    fwrite(fidData,RealTime,'uint32');
end
fclose(fidData); 
end