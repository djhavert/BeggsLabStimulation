function eventSequence=readAndConvertEventSequence(eventLibraryFileNamePathname , eventLibraryFileName)
fid=fopen([eventLibraryFileNamePathname eventLibraryFileName],'r','l');
ESvector=fread(fid,'int32')'; % here the data is just 1-D vector with N*3 elements
fclose(fid);
eventSequence=reshape(ESvector,length(ESvector)/3,3); 
end

