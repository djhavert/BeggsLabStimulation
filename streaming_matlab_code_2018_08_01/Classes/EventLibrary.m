classdef EventLibrary < handle
  properties
    ES = [];
    
  end
  
  methods
    function addSequence(sequence, startTime, chs)
      nP = sequence.nPulses;
      nC = length(chs);
      ESnew = zeros(nP*chs, 3);
      for ii = 1:nC
        ESnew(ii:nC:
      ESnew(:,1) = startTime + sequence.pulseTimes;
      ES
    
  end
end