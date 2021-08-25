classdef PulseLibrary < handle
  properties
    PulseArr = cell(0);
    PL = [];
    PLI = [];
  end
  methods
    function add_Pulse(obj, newPulse)
      % Figure out how to test whether 'newPulse' is in fact a Pulse type
      %succeed = 1;
      % In future, will add way to delete, replace, and edit classes
      obj.PulseArr{length(obj.PulseArr)+1} = newPulse;
      newPL = newPulse.get_PL;
      obj.PL = [obj.PL; newPL];
      if isempty(obj.PLI)
        obj.PLI = 1;
      else
        obj.PLI = [obj.PLI, obj.PLI(end)+size(obj.PulseArr{end-1}.get_PL,1)];
      end
    end
    
    %{
    function create_PL(obj)
      for ii = 1:length(obj.PulseArr)
        obj.PL = [obj.PL; obj.PulseArr{ii}.get_PL];
      end
    end
    %}
    
    function pli = get_PLI(obj)
      pli = obj.PLI;
    end
    
    function pl = get_PL(obj)
      pl = obj.PL;
    end
    
    
    
  end
end