function    newBufferCommand=createBufferCommand(eventFrameCommand,oldBufferCommand,numberOfCountCommandInCurrentWindow)
    newBufferCommand=oldBufferCommand;
    newBufferCommand(numberOfCountCommandInCurrentWindow,:)=eventFrameCommand;
end
