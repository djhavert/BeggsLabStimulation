function [counts,edges] = PSTHcounts(spike_times, stim_times, varargin)

% spike_times - column vector of spike times.
% stim_times - row vector of stim times
%              received as output from function 'getStimTimes.m'
% Nbins - number of bins to split histogram count into
% range - array of size [1,2]. Values give range of times around stimulus
%         to look for spikes. Default is [0 20*100] which will find spikes
%         between 0 and 100 ms after stimulus. Negative values can be used.
%         If input is of size [1,1], it is assumed that start point is 0.
% bCombineOverAllStims - whether to sum counts over every stimulus.
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
Nbins = 100;
range = [0 20*100]; % 0 to 100 ms after stimulus
bCombineOverAllStims = true;

% User defined overrides
ii = 1;
while (ii<=length(varargin))
  switch varargin{ii}
    case 'NumBins'
      Nbins = varargin{ii+1};
      ii=ii+2;
    case 'Range'
      range = varargin{ii+1};
      if size(range) == [1,1]
        range = [0 range];
      elseif size(range) ~= [1,2]
          disp('incorrect format of input variable "range". Please see documentation of PSTHcounts.m');
      end
      ii=ii+2;
    case 'Combine'
      bCombineOverAllStims = varargin{ii+1};
      ii = ii+2;
  end
end


% Setup histogram counting edges
t_start = range(1);
t_end = range(2);
delta_t = (t_end - t_start)/Nbins;
edges = t_start:delta_t:t_end;


% Count Spikes
if bCombineOverAllStims
  counts = zeros(Nbins,1);
  if ~isempty(spike_times)
    for jj = 1:Nbins
      lower = stim_times + edges(jj);
      upper = stim_times + edges(jj+1) - 1;
      counts(jj) = sum(isInRange(spike_times,lower,upper));
    end
  end


elseif ~bCombineOverAllStims
  counts = zeros(Nbins,length(edges)-1);
  for jj = 1:Nbins
    lower = stim_times + edges(jj);
    upper = stim_times + edges(jj+1) - 1;
    for cc = 1:length(lower)
      counts(jj,cc) = sum(isInRange(spike_times,lower(cc),upper(cc)));
    end
  end
end

counts = transpose(counts);

