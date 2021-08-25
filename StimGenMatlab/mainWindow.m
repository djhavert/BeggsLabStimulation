function [nextPartEventSequenceArray,nextPartPulseLibraryArray,nextPartIndexLibraryArray]=mainWindow(previousPartEventSequenceArray,previousPartPulseLibraryArray,previousPartIndexLibraryArray,...
                                                                                            currentPartEventSequenceArray,currentPartPulseLibraryArray,currentPartIndexLibraryArray,maxLengthPulse,TimeWindow,lengthPulseLibraryIndex,numberOfWindow,clockSignal,fidData)


%joining parts from the previous window with the current one                                                                                               
windowEventSequenceArray=[previousPartEventSequenceArray;currentPartEventSequenceArray];
windowPulseLibraryArray=[currentPartPulseLibraryArray,previousPartPulseLibraryArray];
%windowIndexLibraryArray=[previousPartIndexLibraryArray,currentPartIndexLibraryArray];
windowIndexLibraryArray=currentPartIndexLibraryArray;
% if an additional part is prepared for the next window, from the assumption, it is empty, it can be completed
nextPartEventSequenceArray=[];
nextPartPulseLibraryArray=[];
nextPartIndexLibraryArray=[];

if (isempty(windowEventSequenceArray))
    fwrite(fidData, [numberOfWindow,0,0], 'uint32');
else
% Buffer Status
oldBufferSignal=[];
oldBufferCommand=[];
% Window Counters
countNewPartPulseForNextWidnow=0; %Counts how many impulses did not fit in the current window
countPulseInCurrentWindow=0; %Counts how many impulses we are in the current window
countFrameCommandInCurrentWindow=0;%Count how many command frames are in the current window
%the value of the last signal index for the basic version of pulse libraries

nuberWindowIndexLibrary=length(windowIndexLibraryArray)-1;
%doing commands
commandIndexArray = find(windowEventSequenceArray(:,4)<0);% all negative values ??in the 4th column (negative EventIDs)
commandTimeArray=windowEventSequenceArray(commandIndexArray,2);
uniqueCommandArray=unique(commandTimeArray);
countFrameCommandInCurrentWindow=size(uniqueCommandArray,1);
windowEventSequenceCommandArray=windowEventSequenceArray(commandIndexArray,:);
oldBufferCommand=zeros(countFrameCommandInCurrentWindow,1001);

for i=1:countFrameCommandInCurrentWindow
    commandIndexArray=find(windowEventSequenceCommandArray(:,2)==uniqueCommandArray(i));
    numberOfFrameCommandInCurrentWindow=uniqueCommandArray(i);
    eventFrameCommand=createEventFrameCommand(commandIndexArray,numberOfFrameCommandInCurrentWindow,windowEventSequenceCommandArray(commandIndexArray,:),clockSignal);
    newBufferCommand=createBufferCommand(eventFrameCommand,oldBufferCommand,i);
    oldBufferCommand=newBufferCommand;
end

%saving the header 
%header - [window number, Number of Real Time signals, number of command signals]
header=[numberOfWindow,countPulseInCurrentWindow,countFrameCommandInCurrentWindow];
fwrite(fidData, header, 'uint32');

siganlIndexArray = find(windowEventSequenceArray(:,4)>0);% all values 
    if (isempty(siganlIndexArray))
        disp a
    else
    windowEventSequenceSignalArray=windowEventSequenceArray(siganlIndexArray,:);


    outOfRangeIndexArray=find(windowEventSequenceSignalArray(:,2)>=(TimeWindow-(maxLengthPulse)/6)); %suspicious impulses that do not fit in the window

    %making signals
    %first check that it is not empty
    %         windowIndexLibraryArray
    %         lengthPulseLibraryIndex
    %         size(windowPulseLibraryArray)
    if (isempty(outOfRangeIndexArray))
        for i=1:size(windowEventSequenceSignalArray,1)
            startCurrentTimePulse=windowEventSequenceSignalArray(i,2);
            channelNumberSignal=windowEventSequenceSignalArray(i,3); % channelNumber
            startPulseIndex=windowIndexLibraryArray(windowEventSequenceSignalArray(i,4))*6-5;
            lengthCurrentPulse=lengthPulseLibraryIndex(windowEventSequenceSignalArray(i,4));
            partPulseInWindow=windowPulseLibraryArray(:,startPulseIndex:startPulseIndex+(lengthCurrentPulse)-1);
            pulseInSingleChannel=createPulseInSingleChannel(startCurrentTimePulse,channelNumberSignal,partPulseInWindow);%create pulse      
            [currentBufferSignal, removedDataFromCurrentBufferSignal]=removeDataFromBufferSignal(oldBufferSignal,startCurrentTimePulse);  % removing pulses from the buffer, which are below the next value                 
            newBufferSignal=createBufferSignal(pulseInSingleChannel,currentBufferSignal);% adding a pulse to the current buffer
            countPulseInCurrentWindow=releaseBufferSignal(removedDataFromCurrentBufferSignal,countPulseInCurrentWindow,clockSignal,TimeWindow,fidData);
            oldBufferSignal=newBufferSignal;
        end
    else
%         outOfRangeIndexArray(1)
%         for i=1:outOfRangeIndexArray(1)-1
%             startCurrentTimePulse=windowEventSequenceSignalArray(i,2);
%             channelNumberSignal=windowEventSequenceSignalArray(i,3); % channelNumber
%             startPulseIndex=windowIndexLibraryArray(windowEventSequenceSignalArray(i,4))*6+1;
%             lengthCurrentPulse=lengthPulseLibraryIndex(windowEventSequenceSignalArray(i,4));
%             partPulseInWindow=windowPulseLibraryArray(:,startPulseIndex:startPulseIndex+(lengthCurrentPulse)-1)
%             pulseInSingleChannel=createPulseInSingleChannel(startCurrentTimePulse,channelNumberSignal,partPulseInWindow); %stowrznie impulsu      
%             [currentBufferSignal, removedDataFromCurrentBufferSignal]=removeDataFromBufferSignal(oldBufferSignal,startCurrentTimePulse);   % usuniêcie impulsow z bufora, któe sa ponizej wartosci nastepnego                 
%             newBufferSignal=createBufferSignal(pulseInSingleChannel,currentBufferSignal);% dodanie impulsu do obecnego bufora
%             countPulseInCurrentWindow=releaseBufferSignal(removedDataFromCurrentBufferSignal,countPulseInCurrentWindow,clockSignal,TimeWindow,fidData);
%             oldBufferSignal=newBufferSignal;
%         end

        for i=1:length(outOfRangeIndexArray)
           countFrameCommandInCurrentWindow=countFrameCommandInCurrentWindow+1;
           startCurrentTimePulse=windowEventSequenceSignalArray(outOfRangeIndexArray(i),2);%czas rozpoczêcia impulsu podejrzanego o to ¿e nie zmiesci siê w oknie
           lengthCurrentPulse=lengthPulseLibraryIndex(windowEventSequenceSignalArray(outOfRangeIndexArray(i),4))/6; %d³ugoœæ impulsu podejrzanego o to ¿e nie zmiesci siê w oknie
           channelNumberSignal=windowEventSequenceSignalArray(outOfRangeIndexArray(i),3); % channelNumber
           startPulseIndex=windowIndexLibraryArray(windowEventSequenceSignalArray(outOfRangeIndexArray(i),4)); %rozpoczêcie danych które zmieszc¿a sie w tym okni

           if(startCurrentTimePulse+lengthCurrentPulse>=TimeWindow)
%                 disp "nie_zmiesci_sie"
                countNewPartPulseForNextWidnow=countNewPartPulseForNextWidnow+1;%zwiekszenie licznika impulsów, ktore wychodza ponad okno
                nextLengthPulse=startCurrentTimePulse+lengthCurrentPulse-TimeWindow; %tyle nie zmiesci sie w oknie
                currentLengthPulse=lengthCurrentPulse-nextLengthPulse; %tylr zmiesci sie w tym oknie
                endPulseIndex=startPulseIndex+ currentLengthPulse-1;%zakonczenie danych które zmieszc¿a sie w tym okni
                partPulseInWindow=windowPulseLibraryArray(:,(startPulseIndex-1)*6+1:endPulseIndex*6); %dane, wyciete z PulseLibrary ktore sie zmieszcz¹
                partPulseInNextWindow=windowPulseLibraryArray(:,endPulseIndex*6+1:(endPulseIndex+nextLengthPulse)*6); %dane, wyciete z PulseLibrary ktore sie nie zmieszcz¹             


                [nextPartEventSequenceArray,nextPartPulseLibraryArray,nextPartIndexLibraryArray]=createPartPulseForNextWidnow(channelNumberSignal,partPulseInNextWindow,nextLengthPulse,countNewPartPulseForNextWidnow,numberOfWindow,nuberWindowIndexLibrary,nextPartEventSequenceArray,nextPartPulseLibraryArray,nextPartIndexLibraryArray,currentPartIndexLibraryArray);%stworzenie czêscie do nastêpnego okna
                pulseInSingleChannel=createPulseInSingleChannel(startCurrentTimePulse,channelNumberSignal,partPulseInWindow); %stowrznie impulsu      
                [currentBufferSignal, removedDataFromCurrentBufferSignal]=removeDataFromBufferSignal(oldBufferSignal,startCurrentTimePulse);   % usuniêcie impulsow z bufora, któe sa ponizej wartosci nastepnego                 

                newBufferSignal=createBufferSignal(pulseInSingleChannel,currentBufferSignal);% dodanie impulsu do obecnego bufora
                countPulseInCurrentWindow=releaseBufferSignal(removedDataFromCurrentBufferSignal,countPulseInCurrentWindow,clockSignal,TimeWindow,fidData);

                oldBufferSignal=newBufferSignal;
                break
            else

%                 disp "zmiesci_sie"
                %normalnie
                partPulseInWindow=windowPulseLibraryArray(:,startPulseIndex:startPulseIndex+lengthCurrentPulse);
                pulseInSingleChannel=createPulseInSingleChannel(startCurrentTimePulse,channelNumberSignal,partPulseInWindow); %stowrznie impulsu      
                [currentBufferSignal, removedDataFromCurrentBufferSignal]=removeDataFromBufferSignal(oldBufferSignal,startCurrentTimePulse);   % usuniêcie impulsow z bufora, któe sa ponizej wartosci nastepnego                 

                newBufferSignal=createBufferSignal(pulseInSingleChannel,currentBufferSignal);% dodanie impulsu do obecnego bufora
                countPulseInCurrentWindow=releaseBufferSignal(removedDataFromCurrentBufferSignal,countPulseInCurrentWindow,clockSignal,TimeWindow,fidData);
                oldBufferSignal=newBufferSignal;

           end   

        end
    end

% countPulseInCurrentWindow
%         if(countPulseInCurrentWindow~=0)
            countPulseInCurrentWindow=releaseBufferSignal(oldBufferSignal,countPulseInCurrentWindow,clockSignal,TimeWindow,fidData);
            writeCountPulseInCurrentWindow(fidData,countPulseInCurrentWindow)
%         end

    end

bufferCommand=oldBufferCommand;
releaseBufferCommand(bufferCommand,fidData);

end
end



