function [chipNumber, channelNumberInChip] = calculateNumberOfChip(channelNumberGlobal)

channelNumberGlobal=abs(channelNumberGlobal);
chipNumber=0;
    if (channelNumberGlobal>=1 && channelNumberGlobal<=64) 
        chipNumber=1;  
    elseif (channelNumberGlobal>=65 && channelNumberGlobal<=128)
        chipNumber=2;
    elseif (channelNumberGlobal>=129 && channelNumberGlobal<=192)
        chipNumber=3;
    elseif (channelNumberGlobal>=193 && channelNumberGlobal<=256)
        chipNumber=4;
    elseif (channelNumberGlobal>=257 && channelNumberGlobal<=320) 
        chipNumber=5;
    elseif (channelNumberGlobal>=321 && channelNumberGlobal<=384)
        chipNumber=6;
    elseif (channelNumberGlobal>=385 && channelNumberGlobal<=448) 
        chipNumber=7;
    elseif (channelNumberGlobal>=449 && channelNumberGlobal<=512) 
        chipNumber=8;
    end
channelNumberInChip=channelNumberGlobal-((chipNumber-1)*64);


end