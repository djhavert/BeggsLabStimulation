classdef TriphasicPulse
  properties
    amplitude {mustBeInteger, mustBeNonnegative, mustBeLessThan(amplitude,43)} = 0
    duration {mustBeInteger, mustBePositive} = 2
    bIsTest logical = false
    
    pulseShape = [2, -3, 1]
    
    PL {mustBeNumeric} = []
  end
  methods
    % Constructor
    function obj = TriphasicPulse(varargin)
      for ii = 1:2:length(varargin)
        switch(varargin{ii})
          case 'Duration'
            obj.duration = varargin{ii+1};
          case 'Amplitude'
            obj.amplitude = varargin{ii+1};
          case 'IsTest'
            obj.bIsTest = varargin{ii+1};
        end
      end
      obj.PL = obj.createPL();
    end
    
    % Get Functions
    function PL = get_PL(obj)
      PL = obj.PL;
    end
    
    % Set Functions
    function obj = set.PL(obj,PL)
      obj.PL = PL;
    end
  end

    
  methods(Access = protected)
    function PL = createPL(obj)
      PL = [];
      % Pre-Phase %
      % Disconnect the stimulating channel from recording and charge the DAC
      % It is better to charge the DAC value for the first pulse phase in the pre-phase
      DAC7b=obj.amplitude*obj.pulseShape(1);
      if obj.bIsTest
        recOffOnStim = 0;
      else
        recOffOnStim = 1;
      end
      % Define the state of the stimchip - disconnect the channel; the structure is: [0 0 0 0 Connect Record 0 0 polarity DAC7b] - see documentation
      state=[0 0 0 0 0 recOffOnStim 0 0 0 de2bi(abs(DAC7b),7,'left-msb')];
      % Build the PL array which will be eventually saved on the hard drive as the Pulse Library File
      PL=[PL; state];

      for phase=1:length(obj.pulseShape)  % for each phase of the pulse...
        DAC7b=obj.amplitude*obj.pulseShape(phase);
        % The 8th bit of the DAC is the polarity (0=pos, 1=neg)
        if DAC7b>0
            polarity=0;
        else
            polarity=1;
        end
        % 7 bits means limited to 128 values (0-127)
        if abs(DAC7b)>127
            error('The requested value of 7-bit DAC is out of range');
        end
        for j=1:obj.duration % for duration of phase
            state=[0 0 0 0 1 recOffOnStim 0 0 polarity de2bi(abs(DAC7b),7,'left-msb')];
            PL=[PL; state];
        end
      end

      state=[0 0 0 0 0 recOffOnStim 0 0 0 de2bi(abs(DAC7b),7,'left-msb')]; % keep the stimulating channel disconnected for one frame; if one records during the pulse, this has no effect
      PL=[PL; state];
    end
  end
end