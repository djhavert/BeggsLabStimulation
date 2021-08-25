classdef PulseSequence
  properties
    % PulseSequence should stay very general
    SR = 20000;
    
    % Pulse Times in 50 us counts after start of Pulse
    pEvents = cell(0);
    
    % Lust of all current pulse names
    pulseNameList = cell(0);
    
    % Pulse types
    pulseTypeName(1,:) = 'UNDEFINED';
    
    % Duration of pattern in 50 us counts
    duration(1,1) {mustBeInteger, mustBeNonnegative} = 0;
    
    % Number of Pulses
    nPulses(1,1) {mustBeInteger, mustBeNonnegative} = 0;
    
    % Type of Sequence (Custom, Frequency)
    bIsCustom(1,1) logical = false;
    
    % Frequency in Hz
    frequency(1,1) {mustBeNumeric, mustBeNonnegative} = 0;
    
    % Time between each pulse
    tStep(1,1) {mustBeNumeric, mustBeNonnegative} = 0;
    
    %pulseLib = PulseLibrary;
    
    %ES = [];
  end % End Properties
  
  
  % ---Methods---
  methods
    % Constructor
    function obj = PulseSequence(times, pulseType)
      % both are optional inputs
      if nargin > 0
        obj.nPulses = length(times);
        obj.pEvents = cell(obj.nPulses,1);
        for ii = 1:obj.nPulses
          obj.pEvents{ii}.time = times(ii);
        end
        if nargin > 1
          if length(pulseType) == 1
            for ii = 1:obj.nPulses
              obj.pEvents{ii}.eventID = pulseType;
            end
          elseif length(pulseType) == obj.nPulses
            for ii = 1:obj.nPulses
              obj.pEvents{ii}.eventID = pulseType(ii);
            end
          else
            error('Could not create PulseSequence class with that pulseType');
          end
        end
      end 
    end % End Constructor
    
    % Overloaded Set Methods
    %{
    function obj = set.pulseTypeName(obj,input)
      if (length(obj.pulseNameList) == 0)
        error('Must define list of possible pulse types before declaring a pulse type for this pattern');
      end
      if (isnumeric(input))
        if (rem(input,1) == 0 && input > 0 && input <= length(obj.pulseNameList))
          obj.pulseTypeName = obj.pulseNameList{input};
        else
          error([num2str(input),' is not in the range of valid Pulses Indexes']);
        end
      elseif (ischar(input) && ismember(input,obj.pulseNameList))
        obj.pulseTypeName = input;
      else
        error(['''',input, ''' is not a valid Pulse Type. Pulse type must match a name in the current Pulse List']);
      end
    end
    %}
    
    % Calculations
    function tstep = calcTstep(freq)
      tstep = round(1/freq*obj.SR);
    end
        
    function newfreq = calcAllowableFreq(freq)
      obj.tStep = calcTstep(freq);
      newfreq = obj.SR/obj.tstep;
    end
    
    function nPul = calcPulseNum(obj)
      nPul = length(obj.pEvents);
    end
    
    function t = getTimes(obj)
      t = cellfun(@(x) x.time, obj.pEvents, 'UniformOutput', true);
    end
    
    function ch = getChannels(obj)
      ch = cellfun(@(x) x.channel, obj.pEvents, 'UniformOutput', true);
    end
    
    function eID = getEventIDs(obj)
      eID = cellfun(@(x) x.eventID, obj.pEvents, 'UniformOutput', true);
    end
    
    function dur = calcDuration(obj)
      if obj.nPulses ~= 0
        times = obj.getTimes;
        dur = (max(times) - min(times)) + 1;
      else
        dur = 0;
      end     
    end
    
    function PT = calcPulseTimes(obj)
      if (~obj.bIsCustom)
        PT = zeros(1,obj.nPulses);
        for ii = 1:obj.nPulses
          PT(ii) = (ii-1)*obj.tStep;
        end
      end
    end
    
    function obj = addEvent(time, eventID)
      obj.pEvents{end+1} = Event;
      obj.pEvents{end}.time = time;
      obj.pEvents{end}.eventID = eventID;
    end
    
    function obj = setTimes(obj, times)
      if length(times) < obj.nPulses
        obj.pEvents(length(times):obj.nPulses) = [];
      end
      obj.nPulses = length(times);
      for ii = 1:obj.nPulses
        obj.pEvents{ii}.time = times(ii);
      end
    end
    
    function obj = setEventIDs(obj, eventIDs)
      if length(eventIDs) < obj.nPulses
        obj.pEvents(length(eventIDs):obj.nPulses) = [];
      end
      obj.nPulses = length(eventIDs);
      for ii = 1:obj.nPulses
        obj.pEvents{ii}.eventID = eventIDs(ii);
      end
    end
    
    function obj = setEventID(obj, eventID)
      if length(eventID) ~= 1
        error('setEventID function does not accept multiple event IDs');
      else
        for ii = 1:obj.nPulses
          obj.pEvents{ii}.eventID = eventID;
        end
      end
    end
    
    function obj = sort(obj)
      oldTimes = getTimes(obj);
      [newTimes, I] = sort(oldTimes);
      oldEventIDs = getEventIDs(obj);
      newEventIDs = oldEventIDs(I);
      obj = EventSequence(newTimes,newEventIDs);
    end
      
    %function obj = 
  end % End Methods
  
end