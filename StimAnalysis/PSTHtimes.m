function [times] = PSTHtimes(spike_times, stim_times, varargin)

% spike_times - column vector of spike times.
% stim_times - row vector of stim times
%              received as output from function 'getStimTimes.m'
% range - array of size [1,2]. Values give range of times around stimulus
%         to look for spikes. Default is [0 20*100] which will find spikes
%         between 0 and 100 ms after stimulus. Negative values can be used.
%         If input is of size [1,1], it is assumed that start point is 0.
% Return Variables
% counts - #stims by #bins sized array of how many spikes were found in the
%          ranges specified by edges for each separate stimulation time
%          given. If bCombineOverAllStims = 1, size will be 1 by #bins
% edges - optional output. returns the edges used in histogram counting.
%
% DEPENDENCIES
%1) isInRange.m
%
%
% Defaults
range = [0 500]; % 0 to 500 ms after stimulus

% User defined overrides
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
          disp('incorrect format of input variable "range". Please see documentation of PSTHcounts.m');
      end
      ii=ii+2;
    otherwise
      disp([varargin{ii}," is not a recognized input for function PSTHtimes"]);
  end
end


% Find spike times that are within specified range of stim times
times = [];
count = 0;
for stim_idx = 1:length(stim_times)
  time_diffs = spike_times - stim_times(stim_idx);
  time_diffs_in_range = time_diffs(time_diffs > range(1) & time_diffs <= range(2));
  num_added = length(time_diffs_in_range);
  times(count+1:count+num_added) = time_diffs_in_range;
  count = count + num_added;
end

