
function eventSequenceArray=topFunction(TimeWindow,libraryPathname,dataStreamingPathname, libraryFileName,dataStreamingFileName)
% setOptionClkSiganl(saveLocationClkSignal,distance_MUX_ADC);
% clockSignalFile='\clockSignal';
% clockSignal=clkSignal(saveLocationClkSignal,clockSignalFile);
saveLocationClkSignal='clockSignal\';
clockSignalFile='clk';
clockSignal=clkSignal(saveLocationClkSignal,clockSignalFile);
ii = 1;
% Read each of the three files (.slf .sif .sef) and store them

% pulseLibraryArray is original Pulse Library but converted to a (4,6*N)
% array instead of the original (N,16) array. The first four bits of each
% of the 16 bit values are ignored, while the other 12 are copied twice and
% put into a (4,6) array There are N (4,6) arrays concatinated into a
% (4,6*N) array.
pulseLibraryArray=readAndConvertPulseLibrary(libraryPathname.pulseLibraryPathname, libraryFileName.pulseLibraryfName);
% The other two are not changed in any way.
indexLibraryArray=readAndConvertPulseLibraryIndex(libraryPathname.pulseLibraryIndexPathname, libraryFileName.pulseLibraryIndexVectorfName);
eventSequence=readAndConvertEventSequence(libraryPathname.eventLibraryFileNamePathname, libraryFileName.eventLibraryFileName);

Id=length(indexLibraryArray);
PulseLibraryIndex=ones(Id+1,1);

% Convert PLI values to match the new structure of PLF
for i=2:Id
  PulseLibraryIndex(i)=(indexLibraryArray(i)-1)*6+1;
end
PulseLibraryIndex(end)=(length(pulseLibraryArray))+1;

lengthPulseLibraryIndex=zeros(Id,1);

%Gets the lengths of each of the defined pulses in the new PLF format
for i=1:Id
    lengthPulseLibraryIndex(i)=PulseLibraryIndex(i+1)-PulseLibraryIndex(i);
end

maxLengthPulse=max(lengthPulseLibraryIndex);

lengthEventSequence=size(eventSequence,1);

eventSequenceArray=zeros(lengthEventSequence,4);

eventSequenceArray(:,1)=floor(eventSequence(:,1)/TimeWindow);%window number, numbering from zero
eventSequenceArray(:,2)=mod(eventSequence(:,1),TimeWindow);%time within the window
eventSequenceArray(:,3)=eventSequence(:,2);
eventSequenceArray(:,4)=eventSequence(:,3);




% windowEventSequenceArray=[previousPartEventSequenceArray;currentPartEventSequenceArray];
% windowPulseLibraryArray=[currentPartPulseLibraryArray,previousPartPulseLibraryArray];
% windowIndexLibraryArray=[previousPartIndexLibraryArray,currentPartIndexLibraryArray];




% calculateStream(eventSequenceArray,pulseLibraryArray,indexLibraryArray,maxLengthPulse,TimeWindow,lengthPulseLibraryIndex,clockSignal,fidData);

numberOfWindow=eventSequenceArray(end,1); %number of windows
previousPartEventSequenceArray=[];
previousPartPulseLibraryArray=[];
previousPartIndexLibraryArray=[];

% open the binary file for writing and reading
% fidData=fopen([dataStreamingPathname dataStreamingFileName '.bin'],'w+','l');
fidData=fopen([dataStreamingPathname dataStreamingFileName],'w+','l');
% calculateStream(eventSequenceArray,pulseLibraryArray,indexLibraryArray,maxLengthPulse,TimeWindow,lengthPulseLibraryIndex,clockSignal,fidData);

for i=0:numberOfWindow
    i;
    % Display the percentage complete every 100 windows
    if round(i/100)*100==i
        disp(i/numberOfWindow*100);
    end
    indexWindow=find(eventSequenceArray(:,1)==i);
    
    if isempty(indexWindow)
%         disp empty
            currentPartEventSequenceArray=[];
            [nextPartEventSequenceArray,nextPartPulseLibraryArray,nextPartIndexLibraryArray]=mainWindow(previousPartEventSequenceArray,previousPartPulseLibraryArray,previousPartIndexLibraryArray,...
            currentPartEventSequenceArray,pulseLibraryArray,indexLibraryArray,maxLengthPulse,TimeWindow,lengthPulseLibraryIndex,i,clockSignal,fidData);
            
            previousPartEventSequenceArray=nextPartEventSequenceArray;
            previousPartPulseLibraryArray=nextPartPulseLibraryArray;
            previousPartIndexLibraryArray=nextPartIndexLibraryArray;
    else
%         disp not_empty
            currentPartEventSequenceArray=eventSequenceArray(indexWindow(1):indexWindow(end),:);
            ii = ii + 1;
            %disp(ii);
            if ii == 1619
              %disp(ii);
            end
            [nextPartEventSequenceArray,nextPartPulseLibraryArray,nextPartIndexLibraryArray]=mainWindow(previousPartEventSequenceArray,previousPartPulseLibraryArray,previousPartIndexLibraryArray,...
            currentPartEventSequenceArray,pulseLibraryArray,indexLibraryArray,maxLengthPulse,TimeWindow,lengthPulseLibraryIndex,i,clockSignal,fidData);
            
            previousPartEventSequenceArray=nextPartEventSequenceArray;
            previousPartPulseLibraryArray=nextPartPulseLibraryArray;
            previousPartIndexLibraryArray=nextPartIndexLibraryArray;
    end
    %close the file

end

fclose(fidData);      

end

