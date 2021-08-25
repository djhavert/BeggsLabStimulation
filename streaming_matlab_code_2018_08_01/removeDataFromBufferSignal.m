function [currentBufferSignal, removedDataFromCurrentBuffer]=removeDataFromBufferSignal(oldBufferSignal,startTimeSignal)
if(isempty(oldBufferSignal))
    removedDataFromCurrentBuffer=[];
    currentBufferSignal=[];
else    
    removedDataFromCurrentBuffer=oldBufferSignal(oldBufferSignal(:,1)<startTimeSignal,:);
    currentBufferSignal=oldBufferSignal(oldBufferSignal(:,1)>=startTimeSignal,:);
end
end