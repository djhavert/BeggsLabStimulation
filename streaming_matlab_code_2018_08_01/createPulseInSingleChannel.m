function [pulseInSingleChannel]=createPulseInSingleChannel(frameStart,channelNumberGlobal,partLibrary)


%size pulseInSingleChannel is NX9, where 9 is column, N is rows (N is length item in pulse) 

%channel number - chip number
%scheme of pulseInSingleChannel - [ NumberFrame,Indicator, Mask, I32, I32,I32, I32,I32, I32]
%Indicator is correct place pulse in frame, 

%optionReductionArtifact 
%1 mean on globalOptionReductionArtifact
%2 mean off globalOptionReductionArtifact

%1:64 -  chip1
%65:128 -  chip2
%129:192 -  chip3
%193:256 -  chip4
%257:320 -  chip5
%321:384 -  chip6
%385:448 -  chip7
%449:512 -  chip10
%chip number
%1 DIO20-23 Frame0
%2 DIO20-23 Frame1
%3 DIO08-11 Frame0
%4 DIO08-11 Frame1
%5 DIO12-15 Frame0
%6 DIO12-15 Frame1
%7 DIO16-19 Frame0
%8 DIO16-19 Frame1


if (channelNumberGlobal>0)
    optionReductionArtifact=1;
else
    optionReductionArtifact=0;
end

[chipNumber, channelNumberInChip] = calculateNumberOfChip(channelNumberGlobal);
  


    switch chipNumber
            case 1
      partPulseInSingleChannel=uint32(((bitsll(uint32(bi2de(partLibrary(:,:)')), 20))));
            case 3
      partPulseInSingleChannel=uint32(((bitsll(uint32(bi2de(partLibrary(:,:)')), 8))));
            case 5
      partPulseInSingleChannel=uint32(((bitsll(bi2de(partLibrary(:,:)'), 12))));
            case 7
      partPulseInSingleChannel=uint32(((bitsll(bi2de(partLibrary(:,:)'), 16))));
            case 2
      partPulseInSingleChannel=uint32(((bitsll(bi2de(partLibrary(:,:)'), 20))));
            case 4
      partPulseInSingleChannel=uint32(((bitsll(bi2de(partLibrary(:,:)'), 8))));
            case 6
      partPulseInSingleChannel=uint32(((bitsll(bi2de(partLibrary(:,:)'), 12))));
            case 8
      partPulseInSingleChannel=uint32(((bitsll(bi2de(partLibrary(:,:)'), 16))));
    end


lenPartPulseInSingleChannel=length(partPulseInSingleChannel);
partLibrary=[partLibrary,zeros(4,6)];
% size(partLibrary)
maskPart=zeros(lenPartPulseInSingleChannel/6,2);
for i=1:lenPartPulseInSingleChannel/6
 
        if optionReductionArtifact==1

            if [partLibrary(4,(i-1)*6+1),partLibrary(4,i*6+1)]==[0, 1]
                 maskPart(i,:)=[1 0];
            elseif [partLibrary(4,(i-1)*6+1),partLibrary(4,i*6+1)]==[1, 1]
                 maskPart(i,:)=[1 0];
%             elseif [partLibrary(4,(i-1)*6+1),partLibrary(4,i*6+1)]==[1, 0]
%                  maskPart(i,:)=[1 0];

%wazne trzeba to poprawic,bojest cos dziwnego ze wzgledu na ostatni
            end
        else
            maskPart(i,:)=[0, 1]; 

        end

end


% maskPart(end,:)=[0, 1];
mask=zeros(lenPartPulseInSingleChannel/6,8);


         if mod(chipNumber,2)~=1 %parzyste
            mask(:,chipNumber-1:chipNumber)=maskPart(:,:);
         else
            mask(:,chipNumber:chipNumber+1)=maskPart(:,:);
         end
         
%chip1 [maskPart, 0, 0, 0, 0, 0, 0] 1
%chip2 [maskPart, 0, 0, 0, 0, 0, 0] 1
%chip3 [0, 0, maskPart, 0, 0, 0, 0] 2
%chip4 [0, 0, maskPart, 0, 0, 0, 0] 2
%chip5 [0, 0, 0, 0, maskPart, 0, 0] 3
%chip6 [0, 0, 0, 0, maskPart, 0, 0] 3
%chip7 [0, 0, 0, 0, 0, 0, maskPart] 4
%chip8 [0, 0, 0, 0, 0, 0, maskPart] 4
[row,col]=size(mask);
Mask=zeros(row,9);
for i=1:lenPartPulseInSingleChannel/6
   
if optionReductionArtifact==1
    
%      if [partLibrary(4,(i-1)*6+1),partLibrary(4,i*6+1)]==[0, 1]
%              Mask(i,:)=[mask(i,:),1];
%      elseif [partLibrary(4,(i-1)*6+1),partLibrary(4,i*6+1)]==[1, 1]
%              Mask(i,:)=[mask(i,:),1];
%      elseif [partLibrary(4,(i-1)*6+1),partLibrary(4,i*6+1)]==[1, 0]
%              Mask(i,:)=[mask(i,:),1];
%             end
    Mask(i,:)=[mask(i,:),1];
else
    Mask(i,:)=[mask(i,:),0];

end
end
% Mask(end,:)=[mask(end,:),0];

MaskConverted=bi2de(Mask,'right-msb'); %very important



coordinate=zeros(lenPartPulseInSingleChannel/6,2);


        for a=1:(lenPartPulseInSingleChannel/6)
            coordinate(a,1)=(frameStart+(a-1));
            coordinate(a,2)=42+((channelNumberInChip*6)-5);
        end

         if mod(chipNumber,2)~=1
            coordinate(:,2)=coordinate(:,2)+384;
         end
   NumberFrame=coordinate(:,1);
   Indicator=coordinate(:,2);

        tmpPulseInSingleChannel=[reshape(partPulseInSingleChannel,6,lenPartPulseInSingleChannel/6)]';
        pulseInSingleChannel=[NumberFrame,Indicator,MaskConverted,tmpPulseInSingleChannel];
  
end
