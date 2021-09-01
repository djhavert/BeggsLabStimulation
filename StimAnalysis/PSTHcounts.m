function [counts,edges] = PSTHcounts(spike_times, stim_times, varargin)

% spike_times - column vector of spike times.
% stim_times - received as output from function 'getStimTimes.m'
% Nbins - number of bins to split histogram count into
% range - will look for the number of spikes occuring within this number of
%         samples after each stimulation occurence.
% Return Variables
% counts - #stims by #bins array

% Defaults
Nbins = 100;
range = 20*100;
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
      ii=ii+2;
    case 'Combine'
      bCombineOverAllStims = varargin{ii+1};
      ii = ii+2;
  end
end

% Count Spikes

if bCombineOverAllStims
  edges = 0:(range/Nbins):range;
  counts = zeros(Nbins,1);
  if ~isempty(spike_times)
    for jj = 1:Nbins
      lower = stim_times + edges(jj);
      upper = stim_times + edges(jj+1) - 1;
      counts(jj) = sum(isInRange(spike_times,lower,upper));
    end
  end


elseif ~bCombineOverAllStims
  edges = 0:(range/Nbins):range;
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

% Plot
%{
hf = figure();
edges = edges/20; %to get x-axis in ms instead of samples
binMax = max(counts,[],'all');
binMax = ceil(binMax/10)*10;

subplot(2,2,1)
histogram('BinEdges', edges, 'BinCounts', counts(:,1));
xlim([edges(1),edges(end)]);
ylim([0,binMax]);
title(['Stimulation Site: ', num2str(stim_times{1,1})]);
xlabel('time (ms)');
%ylabel(['Ch ',num2str(ch),' response']);

subplot(2,2,2)
histogram('BinEdges', edges, 'BinCounts', counts(:,2));
xlim([edges(1),edges(end)]);
ylim([0,binMax]);
title(['Stimulation Site: ', num2str(stim_times{2,1})]);
xlabel('time (ms)');
%ylabel(['Ch ',num2str(ch),' response']);
sgtitle(['Ch ',num2str(ch),' PSTH']);
%}
