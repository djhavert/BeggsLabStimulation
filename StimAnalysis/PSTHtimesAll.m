function stim_response_times = PSTHtimesALL(asdf, stim_times, varargin)

% 'asdf' - standard asdf cell array.
%
% 'stim_times' - one dimensional cell array where each cell element is a list
% of stimulation times (in ms). The point of the different elements is to
% distunguish between different stimulation patterns.
%
% 'range'(optional) - time period after each stimulation to look for spikes
%
% 'stim_response_times' - For each neuron in asdf and for each stimulation 
% pattern, a vector of relative spike times will be generated for each 
% spike found within the range specified.
%

% Defaults %
range = [0 500]; % 0 to 500 ms after stimulus

% User defined overrides %
ii = 1;
while (ii<=length(varargin))
  switch varargin{ii}
    case 'Range'
      range_in = varargin{ii+1};
      if size(range_in) == [1,1]
        range = [0 range_in];
      elseif size(range_in) == [1,2]
        range = range_in;
      else
          disp('incorrect format of input variable "range". Please see documentation of PSTHcountsAll.m');
      end
      ii=ii+2;
    otherwise
      disp([varargin{ii}," is not a recognized input for function PSTHtimesAll"]);
  end
end

% Initialize %
num_neur = length(asdf) - 2;
if iscell(stim_times)
  num_stim = length(stim_times);
  stim_not_cell = false;
else
  num_stim = 1;
  stim_not_cell = true;
end
stim_response_times = cell(num_neur,num_stim);

% Calculate %
% For each stim pattern
for s = 1:num_stim
  % Get stim times for this pattern
  if (stim_not_cell)
    st = stim_times;
  else
    st = stim_times{s};
  end
  % For each neuron, get response
  for n = 1:num_neur
    stim_response_times{n,s} = PSTHtimes(asdf{n},st,'Range',range);
  end
end