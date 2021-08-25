function neutralFrameCommand=createNeutralFrameCommand(clk)
frameCommand=zeros(1001,1);
frameCommand(2:101)=CommandStop();
frameCommand(902:1001)=CommandStimStart();
frameCommand(2:1001)=frameCommand(2:1001)*(2^26);
frameCommand(2:1001)=frameCommand(2:1001)+stimchipCommandClk()+clk;
neutralFrameCommand=frameCommand;
end