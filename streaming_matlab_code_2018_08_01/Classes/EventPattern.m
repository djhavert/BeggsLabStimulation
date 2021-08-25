classdef EventPattern < handle
  properties
    pulseSequences = cell(0);
    
  end
  methods
    function addSequence(sequence, chs, offset)
      nP = sequence.nPulses;
      nC = length(chs);
      ESnew = zeros(nP*chs, 3);
      for ii = 1:nC
        ESnew(ii:nC:end,1) = 
      ESnew(:,1) = offset + sequence.pulseTimes;
      ES
    
  end
end