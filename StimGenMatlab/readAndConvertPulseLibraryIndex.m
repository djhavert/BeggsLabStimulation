function PulseLibraryIndex=readAndConvertPulseLibraryIndex(pulseLibraryIndexPathname, pulseLibraryIndexVectorfName)

fid=fopen([pulseLibraryIndexPathname pulseLibraryIndexVectorfName],'r','l');
PulseLibraryIndex=fread(fid,'int32')';
fclose(fid);
end

