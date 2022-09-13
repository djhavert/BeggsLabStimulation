function newStateCountPulseInCurrentWindow=releaseBufferSignal(removedDataFromCurrentBufferSignal,oldStateCountPulseInCurrentWindow,clockSignal,TimeWindow,fidData)

rowRemovedDataFromCurrentBufferSignal=size(removedDataFromCurrentBufferSignal,1);

if isempty(removedDataFromCurrentBufferSignal)
    newStateCountPulseInCurrentWindow=oldStateCountPulseInCurrentWindow;
else
    maska=removedDataFromCurrentBufferSignal(:,3)';
    MaskConverted=de2bi(maska,32,'left-msb');
    %1 DIO20-23 Frame0
    %2 DIO20-23 Frame1
    %3 DIO08-11 Frame0
    %4 DIO08-11 Frame1
    %5 DIO12-15 Frame0
    %6 DIO12-15 Frame1
    %7 DIO16-19 Frame0
    %8 DIO16-19 Frame1
    %chip number 
    % % % % %1 DIO16-19 Frame0
    % % % % %2 DIO16-19 Frame1
    % % % % %3 DIO20-23 Frame0
    % % % % %4 DIO20-23 Frame1
    % % % % %5 DIO8-11 Frame0
    % % % % %6 DIO8-11 Frame1
    % % % % %7 DIO12-15 Frame0
    % % % % %8 DIO12-15 Frame1
    for i=1:rowRemovedDataFromCurrentBufferSignal
        removedDataFromCurrentBufferSignal(i,4)=removedDataFromCurrentBufferSignal(i,4)+2236928;%adding a hold key
        removedDataFromCurrentBufferSignal(i,5)=removedDataFromCurrentBufferSignal(i,5)+2236928;
        %removeDataFromCurrentBuffer(i,5)=removeDataFromCurrentBuffer(i,5)+2236928;
        if (MaskConverted(i,1)==1||MaskConverted(i,3)==1||MaskConverted(i,5)==1||MaskConverted(i,7)==1)
             if (MaskConverted(i,1:2)==[0,0])
%                  removeDataFromCurrentBuffer(i,4)=removeDataFromCurrentBuffer(i,4)+524288;
%                  removeDataFromCurrentBuffer(i,5)=removeDataFromCurrentBuffer(i,5)+524288;

%1 i 2
                 removedDataFromCurrentBufferSignal(i,4)=removedDataFromCurrentBufferSignal(i,4)+4194304;
                 removedDataFromCurrentBufferSignal(i,5)=removedDataFromCurrentBufferSignal(i,5)+4194304;
                                 %262144;
             end
             if (MaskConverted(i,3:4)==[0,0])
%                  removeDataFromCurrentBuffer(i,4)=removeDataFromCurrentBuffer(i,4)+4194304;
%                  removeDataFromCurrentBuffer(i,5)=removeDataFromCurrentBuffer(i,5)+4194304;
%3 i 4
                 removedDataFromCurrentBufferSignal(i,4)=removedDataFromCurrentBufferSignal(i,4)+1024;
                 removedDataFromCurrentBufferSignal(i,5)=removedDataFromCurrentBufferSignal(i,5)+1024;
                 %4194304
             end
             if (MaskConverted(i,5:6)==[0,0])
%                  removeDataFromCurrentBuffer(i,4)=removeDataFromCurrentBuffer(i,4)+1024;
%                  removeDataFromCurrentBuffer(i,5)=removeDataFromCurrentBuffer(i,5)+1024;
% 5 i 6
                 removedDataFromCurrentBufferSignal(i,4)=removedDataFromCurrentBufferSignal(i,4)+16384;
                 removedDataFromCurrentBufferSignal(i,5)=removedDataFromCurrentBufferSignal(i,5)+16384;
             end
             if (MaskConverted(i,7:8)==[0,0])
%                  removeDataFromCurrentBuffer(i,4)=removeDataFromCurrentBuffer(i,4)+16384;
%                  removeDataFromCurrentBuffer(i,5)=removeDataFromCurrentBuffer(i,5)+16384;
% 7 i 8
                 removedDataFromCurrentBufferSignal(i,4)=removedDataFromCurrentBufferSignal(i,4)+4194304;
                 removedDataFromCurrentBufferSignal(i,5)=removedDataFromCurrentBufferSignal(i,5)+4194304;

             end
         end
             number=removedDataFromCurrentBufferSignal(i,2); % correction of matrix numbering from zero, suitable for labview
             partCLK=addCLK(clockSignal,number);
             removedDataFromCurrentBufferSignal(i,4:9)=partCLK+removedDataFromCurrentBufferSignal(i,4:9); %addition of clock signals


    end
    
    data=zeros(rowRemovedDataFromCurrentBufferSignal,7);
    for i=1:rowRemovedDataFromCurrentBufferSignal

        if removedDataFromCurrentBufferSignal(i,3)>255
           data(i,1)=removedDataFromCurrentBufferSignal(i,1)*1000+removedDataFromCurrentBufferSignal(i,2)+1000*TimeWindow*2-1; % data(i,1)=removeDataFromCurrentBuffer(i,1)*1000+removeDataFromCurrentBuffer(i,2)+1000*TimeWindow*2-1;
        else
           data(i,1)=removedDataFromCurrentBufferSignal(i,1)*1000+removedDataFromCurrentBufferSignal(i,2)-1;
        end
           data(i,2:7)=removedDataFromCurrentBufferSignal(i,4:end);
   
    end
    [rowFinalVersionbuffor,colFinalVersionbuffor]=size(data);
    data=reshape(data',rowFinalVersionbuffor*colFinalVersionbuffor,1);

    fwrite(fidData, data, 'uint32');
    newStateCountPulseInCurrentWindow=oldStateCountPulseInCurrentWindow+rowRemovedDataFromCurrentBufferSignal;
end
end