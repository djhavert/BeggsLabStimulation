function eventFrameCommand=createEventFrameCommand(commandIndexArray,numberOfFrameCommandInCurrentWindow,windowEventSequenceCommandArray,clockSignal)
neutralFrameCommand=createNeutralFrameCommand(clockSignal);
eventFrameCommand=neutralFrameCommand;
eventFrameCommand(1)=numberOfFrameCommandInCurrentWindow;
    for i=1:length(commandIndexArray)
        commandIndexArray;
        i;
        eventID=windowEventSequenceCommandArray(i,4);
        channelNumber=windowEventSequenceCommandArray(i,3);
        eventFrameCommand(100*i+2:100*(i+1)+1)=eventFrameCommand(100*i+2:100*(i+1)+1)+CommandStimRange(eventID,channelNumber)*2^26;
    end
end