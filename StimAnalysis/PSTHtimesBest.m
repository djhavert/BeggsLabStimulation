function [stim_response_times_best, best_ids] = PSTHtimesBest(asdf, stim_times, varargin)

% 'asdf' - standard asdf cell array.
%
% 'stim_times' - one dimensional cell array where each cell element is a list
% of stimulation times (in ms). The purpose of having a cell array here is 
% to provide a way to separate the stimulation events as you choose. This
% function will return the spike_times in response to each group of events
% separately.
%
% 'Range'(optional) - time period after each stimulation to look for spikes
%
% 'Cutoff'(optional) - the minimum number of spikes a neuron must have
% in response to any of the different stim patterns to not be eliminated.
% If presented as a decimel between 0 and 1, then it is instead interpreted
% as a percentage of neurons to return. For example, if set to 0.1, then
% the top 10% of neurons with the largest stimulus response will be
% returned.
%
% 'stim_response_times_best' - For each neuron in asdf and for each stimulation 
% pattern, a vector of relative spike times will be generated for each 
% spike found within the range specified. Only the neurons with responses
% above a limit will be returned
%
% 'best_ids' - A list of numbers of which neurons in asdf were returned.
%

% Defaults %
range = [0 500]; % 0 to 500 ms after stimulus
cutoff = 101;
cutoff_perc = 0.1;

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
          disp('incorrect format of input variable "Range". Please see documentation of PSTHcountsBest.m');
      end
      ii=ii+2;
    case 'Cutoff'
      cutoff_in = varargin{ii+1};
      if (cutoff_in < 1 && cutoff_in > 0)
        cutoff_perc = cutoff_in;
        % cutoff to be determined later
      elseif (cutoff_in == 0 || cutoff_in >= 1)
        cutoff_perc = 0;
        cutoff = cutoff_in;
      else
        disp('Incorrect format of input variable "Cutoff"Please see documentation of PSTHcountsBest.m');
      end
      ii=ii+2;
    otherwise
      disp([varargin{ii}," is not a recognized input for function PSTHtimesBest"]);
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

% Only return the best neurons. 
% Conditions for best neurons:
% Must have a minimum number of total spikes in response to any of the
% stimulation patterns given.
largest_responses_counts = max(cellfun(@length,stim_response_times),[],2);
if cutoff_perc
  sorted = sort(largest_responses_counts,'descend');
  cutoff = min(sorted(1:ceil(length(sorted)*cutoff_perc)));
end
best_ids = find(largest_responses_counts >= cutoff);
stim_response_times_best = stim_response_times(best_ids,:);