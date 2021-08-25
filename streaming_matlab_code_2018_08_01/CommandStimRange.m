function stimRange=CommandStimRange(eventID,channelNumber)
H=[1 0 1 0]; %header
OC=[1 0 1]; %operating code

range =abs(eventID)-1;
           chipNumber=1;  
%chad - 1 all channels, 0 individually channel, global information
if channelNumber==0
    IA=[1,0,0,0,0,0];
    channel=0;
else
            if (channelNumber>=1 & channelNumber<=64) 
           chipNumber=1;  
           IA=[0,1,1,0,0,1];

            elseif (channelNumber>=65 & channelNumber<=128)
           chipNumber=2; 
           IA=[0,1,1,0,0,1];
            elseif (channelNumber>=129 & channelNumber<=192)
           chipNumber=3;
           IA=[0,1,1,1,1,1];

            elseif (channelNumber>=193 & channelNumber<=256)
           chipNumber=4;
           IA=[0,1,1,1,1,0];
            elseif (channelNumber>=257 & channelNumber<=320) 
           chipNumber=5;
           IA=[0,1,1,1,0,1];
            elseif (channelNumber>=321 & channelNumber<=384)
           chipNumber=6;
           IA=[0,1,1,1,0,0];
            elseif (channelNumber>=385 & channelNumber<=448) 
           chipNumber=7;
           IA=[0,1,1,0,1,1];
            elseif (channelNumber>=449 & channelNumber<=512) 
           chipNumber=8;
           IA=[0,1,1,0,1,0];
           
            end

channel=channelNumber-((chipNumber-1)*64);

end

switch range
    case 0
           R=[0 0 0];
    case 1
           R=[0 0 1];
    case 2
           R=[0 1 0];
    case 3
           R=[0 1 1];
    case 4
           R=[1 0 0];
    case 5
           R=[1 0 1];
    case 6
           R=[1 1 0];
    case 7
           R=[1 1 1];
end
if channelNumber~=0
    chad=0;
    CA=[chad,de2bi(channel-1,6,'left-msb')]; %channel adress
else
    chad=1;
    CA=[chad,de2bi(channel,6,'left-msb')]; %channel adress
end


rangePart=[H, IA, OC, CA, R];

stimRange=zeros(1,100);
for i=1:length(rangePart)
    stimRange(4*i-1)=rangePart(i);
    stimRange(4*i-2)=rangePart(i);
    stimRange(4*i-3)=rangePart(i);
    stimRange(4*i)=rangePart(i);
end
   stimRange=stimRange';
end