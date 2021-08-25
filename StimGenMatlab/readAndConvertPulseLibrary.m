function pulseLibraryArray=readAndConvertPulseLibrary(pulseLibraryPathname, pulseLibraryfName)
%fileName - name of file, 'file.bin'
%rows
%1st row [switch2(discharge), DAC(4), DAC(0)]
%2st row [switch3(hold), DAC(5), DAC(1)]
%3rd row [switch1(record), DAC(6), DAC(2)]
%4th row [switch(connect), polarity, DAC(3)]

fid=fopen([pulseLibraryPathname pulseLibraryfName],'r','l');
PL=fread(fid,'int16')';
fclose(fid);
lengthPL=length(PL);
PL=de2bi(typecast(int16(PL),'uint16'),16);
%PL=reshape(PL,m/16,16);%rozmiar NX16

pulseLibrary=zeros(4,3*lengthPL);
for i=1:lengthPL
    pulseLibrary(4,(i-1)*3+1)=PL(i,5);
    pulseLibrary(3,(i-1)*3+1)=PL(i,6);
    pulseLibrary(2,(i-1)*3+1)=PL(i,7);
    pulseLibrary(1,(i-1)*3+1)=PL(i,8);
    pulseLibrary(4,(i-1)*3+2)=PL(i,9);
    pulseLibrary(3,(i-1)*3+2)=PL(i,10);
    pulseLibrary(2,(i-1)*3+2)=PL(i,11);
    pulseLibrary(1,(i-1)*3+2)=PL(i,12);
    pulseLibrary(4,(i-1)*3+3)=PL(i,13);
    pulseLibrary(3,(i-1)*3+3)=PL(i,14);
    pulseLibrary(2,(i-1)*3+3)=PL(i,15);
    pulseLibrary(1,(i-1)*3+3)=PL(i,16);
end
pulseLibraryArray=zeros(4,2*3*lengthPL);
for j=1:lengthPL
    pulseLibraryArray(:,(j-1)*6+1)=pulseLibrary(:,(j-1)*3+1);
    pulseLibraryArray(:,(j-1)*6+2)=pulseLibrary(:,(j-1)*3+1);
    
    pulseLibraryArray(:,(j-1)*6+3)=pulseLibrary(:,(j-1)*3+2);
    pulseLibraryArray(:,(j-1)*6+4)=pulseLibrary(:,(j-1)*3+2);
    
    pulseLibraryArray(:,(j-1)*6+5)=pulseLibrary(:,(j-1)*3+3);
    pulseLibraryArray(:,(j-1)*6+6)=pulseLibrary(:,(j-1)*3+3);
end
end