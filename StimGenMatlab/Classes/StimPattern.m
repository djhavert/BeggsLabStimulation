classdef StimPattern < handle
  properties
    PLlist = cell(0);
  end
  methods
    function addPulse(obj,Pulse)
      if isempty(obj.PLlist)
        obj.PLlist{1} = Pulse;
      else
        obj.PLlist = {obj.PLlist; Pulse};
      end
    end
    
    function removePulse(obj,Pulse)
      
  end
end